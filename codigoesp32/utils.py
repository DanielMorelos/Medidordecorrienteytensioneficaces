from machine import Pin
def set_gain(level):
    """
    Cambia la ganancia del INA225.
    level: puede ser 25, 50, 100 o 200
    """
    gs0 = Pin(5, Pin.OUT)
    gs1 = Pin(6, Pin.OUT)
    global GANANCIA_ACTUAL, SENS_I
    if level == 25:
        gs0.value(0)
        gs1.value(0)
    elif level == 50:
        gs0.value(0)
        gs1.value(1)
    elif level == 100:
        gs0.value(1)
        gs1.value(0)
    elif level == 200:
        gs0.value(1)
        gs1.value(1)
    else:
        print("Ganancia no válida (usa 25, 50, 100 o 200).")
    SENS_I = GANANCIA_ACTUAL * RSHUNT
    sleep_ms(1) # Minimizamos el delay para estabilización del INA.
