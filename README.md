Medidor de Corriente y Voltaje de Alto Rango con Conectividad Inalámbrica 
Este proyecto presenta el diseño y desarrollo de un sistema avanzado de monitoreo energético inalámbrico de bajo consumo, orientado a aplicaciones residenciales (120 V / 60 Hz o 50Hz). 
El dispositivo permite la adquisición, procesamiento y transmisión en tiempo real de valores eficaces (RMS) de tensión y corriente, integrando una arquitectura híbrida de hardware analógico y software embebido en la nube.  
Características Principales:
-Monitoreo Preciso: Medición sistemática de $V_{RMS}$ e $I_{RMS}$ con actualización cada segundo.  
-Rango Adaptativo: Implementación de una lógica de ganancia dinámica que permite medir desde 10 mA hasta 10 A sin pérdida de resolución.  
-Ecosistema Cloud: Transmisión de datos mediante Wi-Fi a Firebase Realtime Database.  
-Visualización Multiplataforma: Aplicación móvil (Android) y web desarrollada en Flutter para el análisis de registros históricos.  
Especificaciones Técnicas:
Parámetro,Rango / Valor
Tensión Nominal,120 VRMS​   
Frecuencia de Red,60 Hz o 50 Hz   
Rango de Corriente,10 mA a 10 A   
Intervalo de Reporte,1 segundo   
Microcontrolador,ESP32-WROOM-32E (Dual-Core @ 240 MHz)   +1
Arquitectura del Sistema
El dispositivo se fundamenta en dos pilares tecnológicos:
1. Bloque Analógico (Acondicionamiento):
-Sensado de Corriente: Utiliza un resistor shunt de alta precisión (4 mΩ) junto a un amplificador de instrumentación INA225 con arquitectura zero-drift para minimizar errores de offset.
-Sensado de Tensión: Implementa una etapa reductora con el op-amp MCP6002 (rail-to-rail), acoplando la señal mediante un DC Offset de 1.5 V para compatibilidad con el ADC unipolar.
2. Bloque Digital (Procesamiento):
-Firmware: Desarrollado en MicroPython, ejecuta un muestreo sincronizado mediante detección de cruce por cero para garantizar la precisión del cálculo RMS.
-Lógica de Control: Gestiona las ganancias del INA225 (25, 50, 100 o 200 V/V) en tiempo real según la carga detectada.
Estructura del Repositorio/firmware:
-Código fuente en MicroPython para el microcontrolador ESP32.
-/mobile_app: Proyecto Flutter para la aplicación móvil y web de monitoreo.
-/hardware: Esquemáticos y documentación del diseño de la PCB.
Autores
Kevin Rafael Roa Garcia   Daniel Jeshua Morelos Villamizar   Universidad Industrial de Santander (UIS)   
