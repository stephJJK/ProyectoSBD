from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
app.secret_key = 'budget_ecuador_secure_key'

# CONFIGURACIÓN DE BASE DE DATOS
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'admin', 
    'database': 'RENT_A_CAR'
}

def get_db_connection():
    """Establece conexión con manejo de errores."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Error crítico conectando a BD: {e}")
        return None

# --- RUTA 1: DASHBOARD PRINCIPAL ---
@app.route('/')
def dashboard():
    conn = get_db_connection()
    if not conn:
        return "Error de conexión a la Base de Datos. Revisa la consola.", 500
    
    cursor = conn.cursor(dictionary=True)
    
    try:
        # 1. KPIs y Flota (Vista SQL)
        cursor.execute("SELECT * FROM vw_flota_disponible")
        flota = cursor.fetchall()
        
        # 2. Bitácora (Últimos 10 eventos)
        cursor.execute("SELECT * FROM bitacora ORDER BY fecha_hora DESC LIMIT 10")
        bitacora = cursor.fetchall()
        
        # 3. Clientes (Para el formulario de reserva)
        cursor.execute("SELECT id_cliente, nombre_razon_social FROM cliente")
        clientes = cursor.fetchall()
        
        return render_template('dashboard.html', flota=flota, bitacora=bitacora, clientes=clientes)
        
    except Error as e:
        flash(f"Error leyendo datos: {e}", "danger")
        return render_template('dashboard.html', flota=[], bitacora=[], clientes=[])
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

# --- RUTA 2: CREAR RESERVA ---
@app.route('/crear_reserva', methods=['POST'])
def crear_reserva():
    datos = (
        request.form['cliente_id'],
        request.form['categoria_id'],
        request.form['sucursal_retiro'],
        request.form['sucursal_dev'],
        request.form['fecha_retiro'],
        request.form['fecha_devolucion'],
        request.form['placa_vehiculo'] 
    )
    
    conn = get_db_connection()
    if not conn:
        flash("No hay conexión a la base de datos", "danger")
        return redirect(url_for('dashboard'))

    cursor = conn.cursor()
    try:
        cursor.callproc('CrearReserva', datos)
        conn.commit()
        flash('¡Reserva exitosa! El vehículo ha sido reservado.', 'success')
        
    except Error as e:
        flash(f"Error al reservar: {e.msg}", 'danger')
        
    finally:
        cursor.close()
        conn.close()
        
    return redirect(url_for('dashboard'))

# --- RUTA 3: GESTIÓN DE CONTRATOS (HISTORIAL COMPLETO) ---
@app.route('/checkin')
def checkin_page():
    conn = get_db_connection()
    if not conn:
        return redirect(url_for('dashboard'))
        
    cursor = conn.cursor(dictionary=True)
    try:
        query = """
            SELECT c.id_contrato, v.modelo, v.placa, c.fecha_apertura, 
                   cl.nombre_razon_social, c.estado, c.total_pagar, c.fecha_cierre
            FROM contrato c 
            JOIN reserva r ON c.id_reserva = r.id_reserva
            JOIN cliente cl ON r.id_cliente = cl.id_cliente
            JOIN vehiculo v ON c.placa_vehiculo = v.placa 
            ORDER BY c.id_contrato DESC
        """
        cursor.execute(query)
        contratos = cursor.fetchall()
        return render_template('checkin.html', contratos=contratos)
    finally:
        cursor.close()
        conn.close()

# --- RUTA 4: PROCESAR CIERRE (ACTUALIZADA CON MULTAS) ---
@app.route('/cerrar_contrato', methods=['POST'])
def cerrar_contrato():
    # Recibimos los datos del formulario (incluyendo lo nuevo)
    id_contrato = request.form['id_contrato']
    km_llegada = request.form['km_llegada']
    gasolina = request.form['gasolina']
    observaciones = request.form['observaciones']
    monto_adicional = request.form['monto_adicional']
    
    # Si el campo de multa viene vacío, ponemos 0
    if not monto_adicional:
        monto_adicional = 0
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # Llamamos al procedimiento con los 5 argumentos
        cursor.callproc('CerrarContrato', [id_contrato, km_llegada, gasolina, observaciones, monto_adicional])
        conn.commit()
        flash('Vehículo devuelto. Se han registrado las observaciones y cargos adicionales.', 'success')
    except Error as e:
        flash(f"Error en cierre: {e.msg}", 'danger')
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('checkin_page'))

# --- RUTA 5: CANCELAR CONTRATO (ANULAR) ---
@app.route('/cancelar_contrato/<int:id_contrato>', methods=['POST'])
def cancelar_contrato(id_contrato):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT placa_vehiculo FROM contrato WHERE id_contrato = %s", (id_contrato,))
        resultado = cursor.fetchone()
        
        if resultado:
            placa = resultado[0]
            cursor.execute("UPDATE vehiculo SET estado = 'Disponible' WHERE placa = %s", (placa,))
            cursor.execute("UPDATE contrato SET estado = 'Cancelado', fecha_cierre = NOW() WHERE id_contrato = %s", (id_contrato,))
            conn.commit()
            flash('Contrato ANULADO. El vehículo está disponible nuevamente.', 'warning')
        else:
            flash('No se encontró el contrato especificado.', 'danger')
            
    except Error as e:
        flash(f"Error al cancelar: {e.msg}", 'danger')
    finally:
        cursor.close()
        conn.close()
        
    return redirect(url_for('checkin_page'))

# --- RUTA 6: LISTA DE CLIENTES (NUEVO) ---
@app.route('/clientes')
def clientes_page():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM cliente ORDER BY id_cliente DESC")
        clientes = cursor.fetchall()
        return render_template('clientes.html', clientes=clientes)
    finally:
        cursor.close()
        conn.close()

# --- RUTA 7: CREAR CLIENTE (NUEVO) ---
@app.route('/crear_cliente', methods=['POST'])
def crear_cliente():
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # Manejo de campos opcionales para empresas
        licencia = request.form['licencia'] if request.form['licencia'] else None
        vigencia = request.form['vigencia'] if request.form['vigencia'] else None

        query = """
            INSERT INTO cliente (tipo_cliente, identificacion, nombre_razon_social, licencia_conducir, vigencia_licencia, contacto)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (
            request.form['tipo_cliente'], 
            request.form['identificacion'], 
            request.form['nombre'], 
            licencia, 
            vigencia, 
            request.form['contacto']
        ))
        conn.commit()
        flash('Cliente registrado exitosamente.', 'success')
    except Error as e:
        flash(f"Error al crear cliente: {e.msg}", 'danger')
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('clientes_page'))

# --- RUTA 8: HISTORIAL DETALLADO DE CLIENTE (NUEVO) ---
@app.route('/historial_cliente/<int:id_cliente>')
def historial_cliente(id_cliente):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        # Datos del Cliente
        cursor.execute("SELECT * FROM cliente WHERE id_cliente = %s", (id_cliente,))
        cliente = cursor.fetchone()

        # Historial de Rentas (Con Observaciones de Inspección)
        query = """
            SELECT 
                c.id_contrato,
                v.modelo,
                v.placa,
                c.fecha_apertura,
                c.fecha_cierre,
                c.total_pagar,
                c.estado,
                i.observaciones
            FROM contrato c
            JOIN reserva r ON c.id_reserva = r.id_reserva
            JOIN vehiculo v ON c.placa_vehiculo = v.placa
            LEFT JOIN inspeccion i ON c.id_contrato = i.id_contrato AND i.tipo = 'Check-In'
            WHERE r.id_cliente = %s
            ORDER BY c.fecha_apertura DESC
        """
        cursor.execute(query, (id_cliente,))
        historial = cursor.fetchall()
        
        return render_template('historial_cliente.html', cliente=cliente, historial=historial)
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)