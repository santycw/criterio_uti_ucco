import streamlit as st

# ==========================================
# CONFIGURACIÓN DE PÁGINA
# ==========================================
st.set_page_config(page_title="Triage UCI", page_icon="🏥", layout="wide")
st.markdown("<h1 style='text-align: center; color: #2c3e50;'>Protocolo de Triage y Reserva Funcional UCI</h1>", unsafe_allow_html=True)
st.markdown("---")

# ==========================================
# DICCIONARIOS MÉDICOS
# ==========================================
cfs_dict = {
    '1 - Muy en forma: Robusto, activo, enérgico.': 1,
    '2 - En forma: Sin enfermedad activa.': 2,
    '3 - Bien: Problemas médicos controlados.': 3,
    '4 - Vulnerable: No dependiente, síntomas limitantes.': 4,
    '5 - Levemente frágil: Ayuda en AIVD.': 5,
    '6 - Moderadamente frágil: Ayuda en ABVD.': 6,
    '7 - Severamente frágil: Dependiente total, estable.': 7,
    '8 - Muy severamente frágil: Acercándose al fin de la vida.': 8,
    '9 - Enfermo terminal: Expectativa < 6 meses.': 9
}

ecog_dict = {
    '0 - Totalmente activo.': 0,
    '1 - Restricción para trabajo físico extenuante.': 1,
    '2 - Ambulatorio, autocuidado, sin capacidad laboral.': 2,
    '3 - Autocuidado limitado. Cama/silla >50%.': 3,
    '4 - Totalmente incapacitado. Cama/silla 100%.': 4
}

fast_dict = {
    '1 - Normal.': '1', '2 - Olvido normal.': '2', '3 - Deterioro cognitivo leve.': '3',
    '4 - Leve (Dificultad en tareas complejas).': '4', '5 - Moderada (Requiere ayuda para elegir ropa).': '5',
    '6 - Moderadamente severa (Ayuda para ABVD).': '6', '7 - Severa (Pérdida de habla, deambulación).': '7'
}

# Puntajes de Barthel
b_3_opc = {'Independiente': 10, 'Necesita ayuda': 5, 'Dependiente': 0}
b_2_opc = {'Independiente': 5, 'Dependiente': 0}
b_esfinteres = {'Continente': 10, 'Accidente ocasional': 5, 'Incontinente': 0}
b_traslado = {'Independiente': 15, 'Mínima ayuda': 10, 'Gran ayuda': 5, 'Dependiente': 0}
b_deambular = {'Independiente': 15, 'Necesita ayuda': 10, 'Independiente silla ruedas': 5, 'Dependiente': 0}

# ==========================================
# INTERFAZ DE USUARIO (GRID LAYOUT)
# ==========================================
col_izq, col_der = st.columns([1.2, 1])

with col_izq:
    st.subheader("A. Evaluación Geriátrica, Cognitiva y Funcional")
    sel_cfs = st.selectbox("CFS (Fragilidad Clínica):", list(cfs_dict.keys()))
    sel_ecog = st.selectbox("ECOG Performance Status:", list(ecog_dict.keys()))
    sel_fast = st.selectbox("FAST (Estadio de Demencia):", list(fast_dict.keys()))

    st.subheader("Índice de Barthel (ABVD)")
    b1, b2 = st.columns(2)
    with b1:
        comer = st.selectbox("Comer:", list(b_3_opc.keys()), key='comer')
        lavarse = st.selectbox("Lavarse:", list(b_2_opc.keys()), key='lavarse')
        vestirse = st.selectbox("Vestirse:", list(b_3_opc.keys()), key='vestirse')
        arreglarse = st.selectbox("Arreglarse:", list(b_2_opc.keys()), key='arreglarse')
        deposiciones = st.selectbox("Deposiciones:", list(b_esfinteres.keys()), key='dep')
    with b2:
        miccion = st.selectbox("Micción:", list(b_esfinteres.keys()), key='mic')
        retrete = st.selectbox("Uso Retrete:", list(b_3_opc.keys()), key='retrete')
        traslado = st.selectbox("Traslado:", list(b_traslado.keys()), key='traslado')
        deambular = st.selectbox("Deambular:", list(b_deambular.keys()), key='deambular')
        escaleras = st.selectbox("Escaleras:", list(b_3_opc.
