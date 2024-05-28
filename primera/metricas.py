from prometheus_client import start_http_server, Gauge
import random
import time

metrica = Gauge('Prueba', 'Alejandro Monsalve')

def update_metrics():
    while True:
        metrica.set(random.randint(0, 100))
        time.sleep(5)

if __name__ == '__main__':
    start_http_server(8000)
    update_metrics()
