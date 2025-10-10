from machine import Pin, I2C, ADC
from i2c_lcd1602 import I2C_LCD1602
from time import ticks_us
from time import sleep_ms
import math

# Parametros #
OFFSET_V = 1.47	
OFFSET_I = 1.47
RSHUNT = 0.004
SENS_I = 24.79 * RSHUNT   
CAL_V = 0.008256 

# --- Ganancias del INA225 para podoer calibrarlas ---
G_25 = 24.79 
G_50 = 49.56
G_100 = 99.16
G_200 = 200

## Funcion para definir ganancia
def set_gain(level):
    """
    Cambia la ganancia del INA225 y actualiza la variable global.
    """
    global GANANCIA_ACTUAL, SENS_I
    if level == 25:
        gs1.value(0); gs0.value(0); GANANCIA_ACTUAL = G_25
    elif level == 50:
        gs1.value(1); gs0.value(0); GANANCIA_ACTUAL = G_50
    elif level == 100:
        gs1.value(0); gs0.value(1); GANANCIA_ACTUAL = G_100
    elif level == 200:
        gs1.value(1); gs0.value(1); GANANCIA_ACTUAL = G_200
    
    
    SENS_I = GANANCIA_ACTUAL * RSHUNT
    sleep_ms(1) # Para darle tiempo a la INA de estabilizar la ganancia

    
# --- Umbrales de corriente

UMBRAL_BAJAR_100 = 1.3 # Si I_PICO > 1.3A, bajamos a G=100 
UMBRAL_BAJAR_50  = 2.5 # Si I_PICO > 2.5A, bajamos a G=50 
UMBRAL_BAJAR_25  = 5.0 # Si I_PICO > 5.0A, bajamos a G=25 
# Umbral para subir:
UMBRAL_SUBIR_200 = 0.5 # Si I_PICO < 0.5A, subimos a G=200
UMBRAL_SUBIR_100 = 1.0 # Si I_PICO < 1.0A, subimos a G=100
UMBRAL_SUBIR_50  = 2.0 # Si I_PICO < 2.0A, subimos a G=50

# ------- Configuracion ADC -------#
adc_v = ADC(Pin(1))
adc_i = ADC(Pin(2))
adc_v.width(ADC.WIDTH_12BIT)
adc_i.width(ADC.WIDTH_12BIT)
adc_v.atten(ADC.ATTEN_11DB)
adc_i.atten(ADC.ATTEN_11DB)

# -------- Configuracion ganancia inicial ----- #
gs0 = Pin(5, Pin.OUT)
gs1 = Pin(6, Pin.OUT)
GANANCIA_ACTUAL = 25
set_gain(25)

# 25 v/v


# Configuracion LCD#
i2c = I2C(0, scl=Pin(12), sda=Pin(11))
lcd = I2C_LCD1602(i2c, 63)


## Muestreo parametros
samples_per_cycle = 32
cycles_window = 10                   
fs = samples_per_cycle * 60          
dt_us = int(1_000_000 / fs)          
total_samples = samples_per_cycle * cycles_window


def wait_for_zero_cross():
    prev_v = adc_v.read_uv() / 1_000_000 - OFFSET_V
    while True:
        v_now = adc_v.read_uv() / 1_000_000 - OFFSET_V
        if prev_v < 0 and v_now >= 0:
            return 
        prev_v = v_now
sleep_ms(1000)

while True:
    wait_for_zero_cross()
    set_gain(25)
    
    pre_samples = samples_per_cycle * 2
    max_peak_v = 0
    
    t_next_pre = ticks_us()
    for _ in range(pre_samples):
        while ticks_us() < t_next_pre:
            pass
        t_next_pre += dt_us
        
        v_adci = adc_i.read_uv() / 1_000_000
        vi_ac = abs(v_adci - OFFSET_I) 
        if vi_ac > max_peak_v:
            max_peak_v = vi_ac

    i_peak = max_peak_v / (G_25 * RSHUNT)
    
    # d) Aplicamos la lógica para elegir la GANANCIA FINAL
    if i_peak < UMBRAL_SUBIR_200:
        g_final = 200
    elif i_peak < UMBRAL_SUBIR_100:
        g_final = 100
    elif i_peak < UMBRAL_SUBIR_50:
        g_final = 50
    else: # I_PICO > 5.0A, o si es muy alta
        g_final = 25
	
    set_gain(g_final)  
    
    #------- Medicion oficial -----#
    wait_for_zero_cross()
    sum_sq_v = 0.0
    sum_sq_i = 0.0
    t_next = ticks_us() 
    for _ in range(total_samples):
        while ticks_us() < t_next:
           pass
	   
        t_next += dt_us

        v_adc = adc_v.read_uv() / 1_000_000
        v_ac = v_adc - OFFSET_V
        sum_sq_v += v_ac * v_ac

        v_adci = adc_i.read_uv() / 1_000_000
        print(v_adci)
        vi_ac = v_adci - OFFSET_I
	
        i_ac = vi_ac / SENS_I
        sum_sq_i += i_ac * i_ac

    
    rms_v = (math.sqrt(sum_sq_v / total_samples)) / CAL_V
    rms_i = math.sqrt(sum_sq_i / total_samples)

 
    lcd.clear()
    lcd.puts("V={:.2f} Vrms".format(rms_v), 0, 0)
    lcd.puts("I={:.3f} Arms".format(rms_i), 0, 1)