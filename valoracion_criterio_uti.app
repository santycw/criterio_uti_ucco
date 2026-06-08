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
        escaleras = st.selectbox("Escaleras:", list(b_3_opc.keys()), key='escaleras')

with col_der:
    st.subheader("B. Criterios de Exclusión")
    st.markdown("*(Comorbilidades Crónicas Terminales)*")
    exc_onco = st.checkbox("Oncológico Terminal / Metástasis refractaria")
    exc_epoc = st.checkbox("EPOC Severo / O2 Dependiente basal")

# ==========================================
# MOTOR LÓGICO Y CÁLCULO DE ALERTAS
# ==========================================
puntaje_barthel = (
    b_3_opc[comer] + b_2_opc[lavarse] + b_3_opc[vestirse] + b_2_opc[arreglarse] +
    b_esfinteres[deposiciones] + b_esfinteres[miccion] + b_3_opc[retrete] +
    b_traslado[traslado] + b_deambular[deambular] + b_3_opc[escaleras]
)

cfs_val = cfs_dict[sel_cfs]
ecog_val = ecog_dict[sel_ecog]
fast_val = fast_dict[sel_fast]

motivos_exclusion = []
if cfs_val >= 7: motivos_exclusion.append(f"Fragilidad Severa (CFS {cfs_val})")
if ecog_val == 4: motivos_exclusion.append("Performance Status basal ECOG 4")
if puntaje_barthel < 20: motivos_exclusion.append(f"Dependencia total en ABVD (Barthel {puntaje_barthel}/100)")
if fast_val == '7': motivos_exclusion.append("Demencia en estadio avanzado (FAST 7)")
if exc_onco: motivos_exclusion.append("Enfermedad oncológica terminal")
if exc_epoc: motivos_exclusion.append("Enfermedad respiratoria crónica terminal")

# ==========================================
# PANEL SUPERIOR DE RESOLUCIÓN MÉDICA
# ==========================================
st.markdown("---")
# Utilizo contenedores para posicionar la alerta visualmente destacada
alerta_container = st.container()

with alerta_container:
    if len(motivos_exclusion) > 0:
        texto_motivos = "\n".join([f"- {m}" for m in motivos_exclusion])
        st.error(f"**⚠️ RECOMENDACIÓN DE LIMITACIÓN DEL ESFUERZO TERAPÉUTICO (LET)**\n\nEl paciente presenta predictores de futilidad clínica para medidas invasivas:\n{texto_motivos}\n\n*Acción sugerida: Reevaluar el ingreso a UCI y considerar abordaje paliativo. Puntaje Barthel actual: {puntaje_barthel}/100.*", icon="🚨")
    else:
        st.success(f"**✅ CUALIFICA PARA INGRESO / SOPORTE TOTAL**\n\nReserva funcional aceptable. Barthel calculado: {puntaje_barthel}/100. No se detectan contraindicaciones absolutas derivadas del performance status previo.", icon="✅")
