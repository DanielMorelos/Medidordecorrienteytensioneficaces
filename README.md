# High-Range IoT Current and Voltage Meter

[English](#english) · [Español](#español)

---

## English

Design of a battery-powered wireless energy meter for residential use (120 V, 60 Hz). It measures RMS voltage and current from 10 mA to 10 A, sends the values to Firebase once per second, and shows them in a Flutter app for Android and web. The analog circuit was validated in Proteus and the PCB was designed in EasyEDA. Course project, *Diseño de Sistemas Electrónicos* (UIS, 2025-2).

### Features

- RMS voltage and current, one reading per second.
- Adaptive gain (25, 50, 100 or 200 V/V) to cover 10 mA to 10 A without saturating the ADC.
- Wi-Fi transmission to Firebase Realtime Database.
- Android and web app with a measurement table and plots over time.

### Specifications

| Parameter | Value |
| :--- | :--- |
| Nominal voltage | 120 V<sub>RMS</sub> |
| Line frequency | 60 Hz |
| Current range | 10 mA to 10 A |
| Reporting interval | 1 s |
| Microcontroller | ESP32-WROOM-32E |
| Communication | Wi-Fi (Firebase RTDB) |
| Power | External 3.7 V Li-ion battery or USB-C |
| PCB size | 31.2 × 29.1 mm |

### System architecture

**Analog front end**

- Current sensing: 4 mΩ shunt resistor with an INA225 zero-drift amplifier, which keeps offset error low.
- Voltage sensing: resistive divider and MCP6002 rail-to-rail op-amp, with a 1.5 V DC offset so the signal fits the unipolar ADC.

**Digital processing**

- Firmware in MicroPython. Sampling is synchronized to the zero crossing of the mains signal, so the RMS calculation covers whole cycles.
- The INA225 gain is selected in real time according to the detected load.

**Cloud and app**

- The ESP32 writes each measurement to Firebase Realtime Database.
- The Flutter app loads the latest 100 records and displays them in a table and charts.

### Results

- Simulated readings in Proteus: 119.99 V and 10 mA, and 119.98 V and 1.001 A.
- Estimated accuracy of 1 % to 2 % between 1 A and 10 A.
- Near 10 mA the internal 12-bit ADC gives only about 12 steps, so readings are less certain. The report proposes software calibration or an external 16-bit ADC (AD7680) to improve this.
- Estimated bill of materials: about USD 27.7.

### Repository structure

```
Informe/       Project report (PDF)
codigoesp32/   MicroPython code for the ESP32
medidoriv/     Flutter project (Android and web)
imagenes/      Images used in the documentation
```

The app has its own README with setup instructions in `medidoriv/`.

### Authors

Kevin Rafael Roa Garcia and Daniel Jeshua Morelos Villamizar
Universidad Industrial de Santander (UIS), 2025

---

## Español

Diseño de un medidor de energía inalámbrico alimentado por batería para uso residencial (120 V, 60 Hz). Mide tensión y corriente RMS desde 10 mA hasta 10 A, envía los valores a Firebase cada segundo y los muestra en una aplicación Flutter para Android y web. El circuito analógico se validó en Proteus y la PCB se diseñó en EasyEDA. Proyecto del curso *Diseño de Sistemas Electrónicos* (UIS, 2025-2).

### Funcionalidades

- Tensión y corriente RMS, una lectura por segundo.
- Ganancia adaptativa (25, 50, 100 o 200 V/V) para cubrir de 10 mA a 10 A sin saturar el ADC.
- Transmisión por Wi-Fi a Firebase Realtime Database.
- Aplicación Android y web con tabla de mediciones y gráficas en el tiempo.

### Especificaciones

| Parámetro | Valor |
| :--- | :--- |
| Tensión nominal | 120 V<sub>RMS</sub> |
| Frecuencia de red | 60 Hz |
| Rango de corriente | 10 mA a 10 A |
| Intervalo de reporte | 1 s |
| Microcontrolador | ESP32-WROOM-32E |
| Comunicación | Wi-Fi (Firebase RTDB) |
| Alimentación | Batería Li-ion 3.7 V externa o USB-C |
| Tamaño de la PCB | 31.2 × 29.1 mm |

### Arquitectura del sistema

**Acondicionamiento analógico**

- Sensado de corriente: resistor shunt de 4 mΩ con amplificador INA225 de tipo zero-drift, que mantiene bajo el error de offset.
- Sensado de tensión: divisor resistivo y op-amp MCP6002 rail-to-rail, con un offset DC de 1.5 V para que la señal sea compatible con el ADC unipolar.

**Procesamiento digital**

- Firmware en MicroPython. El muestreo se sincroniza con el cruce por cero de la red, de modo que el cálculo RMS abarque ciclos completos.
- La ganancia del INA225 se selecciona en tiempo real según la carga detectada.

**Nube y aplicación**

- El ESP32 escribe cada medición en Firebase Realtime Database.
- La aplicación Flutter carga los últimos 100 registros y los muestra en una tabla y en gráficas.

### Resultados

- Lecturas simuladas en Proteus: 119.99 V y 10 mA, y 119.98 V y 1.001 A.
- Exactitud estimada de 1 % a 2 % entre 1 A y 10 A.
- Cerca de 10 mA el ADC interno de 12 bits entrega solo unos 12 pasos, por lo que las lecturas son menos confiables. El informe propone calibración por software o un ADC externo de 16 bits (AD7680) para mejorarlo.
- Costo estimado de materiales: cerca de USD 27.7.

### Estructura del repositorio

```
Informe/       Informe del proyecto (PDF)
codigoesp32/   Código en MicroPython para el ESP32
medidoriv/     Proyecto Flutter (Android y web)
imagenes/      Imágenes usadas en la documentación
```

La aplicación tiene su propio README con las instrucciones de instalación en `medidoriv/`.

### Autores

Kevin Rafael Roa Garcia y Daniel Jeshua Morelos Villamizar
Universidad Industrial de Santander (UIS), 2025
