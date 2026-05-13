# Taller de Evaluación de Rendimiento

> Sistemas Operativos · Pontificia Universidad Javeriana  
> Semestre 2026-1

---

## Descripción

Este proyecto implementa y evalúa cuatro variantes de multiplicación de matrices cuadradas en C, combinando dos mecanismos de paralelismo — procesos (`fork`) e hilos POSIX (`pthreads`) — con dos estrategias de acceso a memoria: acceso clásico por columnas (FxC) y acceso optimizado mediante transposición de la matriz operando (FxT).

El objetivo es cuantificar el impacto que tienen el modelo de concurrencia y la localidad espacial de memoria sobre el tiempo de ejecución, variando sistemáticamente el tamaño de la matriz (200 a 3200) y el número de workers (1, 2 y 4). Cada combinación se repite 30 veces para obtener mediciones estadísticamente representativas.

---

## Implementaciones comparadas

| Ejecutable | Paralelismo | Acceso a B | Descripción |
|---|---|---|---|
| `mxmForkFxC` | `fork()` | Por columnas | Algoritmo clásico con procesos |
| `mxmForkFxT` | `fork()` | Transpuesta | Optimización de caché con procesos |
| `mxmPosixFxC` | Pthreads | Por columnas | Algoritmo clásico con hilos |
| `mxmPosixFxT` | Pthreads | Transpuesta | Optimización de caché con hilos |

**Sobre la optimización por transposición:**  
En el acceso clásico FxC, la matriz B se recorre saltando entre filas en memoria, lo que genera una alta tasa de *cache misses*. Al calcular previamente su transpuesta, ambas matrices se recorren de forma contigua durante la multiplicación, mejorando significativamente la localidad espacial y reduciendo el tiempo de ejecución en matrices de gran dimensión.

---

## Estructura del proyecto

```
evalRend2610/
├── src/
│   ├── moduloMM.c      # Funciones compartidas: inicialización, transposición, medición de tiempo
│   ├── moduloMM.h      # Prototipos del módulo compartido
│   ├── mxmForkFxC.c    # MxM con fork(), acceso clásico por columnas
│   ├── mxmForkFxT.c    # MxM con fork(), acceso por transpuesta
│   ├── mxmPosixFxC.c   # MxM con Pthreads, acceso clásico por columnas
│   └── mxmPosixFxT.c   # MxM con Pthreads, acceso por transpuesta
├── Soluciones/         # Archivos .dat con las 30 muestras por combinación
└── lanzador.pl         # Script Perl de automatización de experimentos
```

---

## Compilación

```bash
make
```

Genera los cuatro ejecutables. Para eliminar los archivos compilados:

```bash
make clean
```

---

## Ejecución manual

```bash
./<ejecutable> <tamMatriz> <numWorkers>
```

**Ejemplos:**
```bash
./mxmPosixFxT 800 4    # Pthreads + transpuesta, matriz 800×800, 4 hilos
./mxmForkFxC  1600 2   # fork() + clásico, matriz 1600×1600, 2 procesos
```

El programa imprime el tiempo de ejecución en **microsegundos** (µs). Si la dimensión de la matriz es inferior a 13, también se imprime su contenido para verificar la corrección del resultado.

---

## Ejecución automatizada

El script `lanzador.pl` ejecuta de forma automática todas las combinaciones de experimentos y almacena los resultados en `Soluciones/`:

```bash
perl lanzador.pl
```

Cubre la totalidad del espacio experimental:
- **4 ejecutables** × **4 tamaños de matriz** (200, 800, 1600, 3200) × **3 configuraciones de workers** (1, 2, 4) = **48 archivos `.dat`**
- Cada archivo contiene **30 mediciones** independientes de tiempo en µs

Los archivos de resultados siguen la convención de nombres:
```
Soluciones/<ejecutable>-<tamMatriz>-Hilos-<numWorkers>.dat
```

---

## Resultados

Los archivos `.dat` en `Soluciones/` registran los tiempos de ejecución crudos en µs, una medición por línea. A partir de estos datos pueden derivarse métricas como promedio, desviación estándar y speedup para cada configuración experimental.

**Formato de un archivo `.dat`:**
```
   11814 
   11522 
   17930 
   11718 
   ...    (30 muestras en total)
```

---

## Variables del experimento

| Variable | Valores |
|---|---|
| Tamaño de matriz (N×N) | 200, 800, 1600, 3200 |
| Número de workers | 1, 2, 4 |
| Repeticiones por combinación | 30 |
| Modelo de paralelismo | `fork()`, Pthreads |
| Estrategia de acceso a memoria | FxC (columnas), FxT (transpuesta) |

---

## Conceptos aplicados

- `fork()` / `wait()` — Paralelismo mediante procesos independientes
- `pthread_create()` / `pthread_join()` — Paralelismo mediante hilos POSIX
- `pthread_mutex_t` — Control de acceso en secciones críticas
- `gettimeofday()` — Medición de tiempo con resolución de microsegundos
- Transposición de matrices para optimización de localidad espacial en caché
- Automatización de experimentos mediante scripting en Perl

---

## Observaciones

- Las implementaciones con **transpuesta (FxT) presentan tiempos de ejecución significativamente menores** que sus equivalentes clásicos (FxC) a partir de matrices de tamaño medio, como consecuencia directa de la mejora en localidad de caché.
- **Pthreads supera consistentemente a `fork()`** en términos de rendimiento, dado que la creación de hilos implica un overhead considerablemente menor que la creación de procesos.
- El escalado con el número de workers no es lineal: la contención de memoria y el costo de sincronización introducen un límite práctico al speedup obtenible.
- Para matrices de dimensión reducida (200×200), el overhead de gestión de workers puede anular el beneficio del paralelismo.

---

## Entorno de desarrollo

- Ubuntu 22.04 / 24.04
- GCC 11+ con flags `-O3`, `-lm`, `-lpthread`
- Perl 5 (script de automatización)

---

*Trabajo académico – Sistemas Operativos, Pontificia Universidad Javeriana, 2026.*
