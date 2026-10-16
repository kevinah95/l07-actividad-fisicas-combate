# Lección 07: Físicas 2D, Proyectiles Balísticos y Sistema de Combate
> **Curso:** Desarrollo de Videojuegos 2D con Kotlin Multiplatform & KorGE  
> **Proyecto:** Norman The Necromancer  
> **Documento Fuente para Google NotebookLM** (Presentaciones, Estudio y Audio Overview)

---

## 📋 Ficha Técnica de la Lección

- **Lección:** 07 de 12
- **Tema:** Motor de físicas 2D por integración de Euler, detección geométrica AABB, máscaras de bits (Bitmasks) y proyectiles balísticos con parábola.
- **Prerrequisito:** Lección 06 (Sprites, Bitmaps y renderizado en Compose Multiplatform / KorGE).
- **Siguiente Lección:** Lección 08 (Nigromancia: Resurrección de esqueletos a partir de cadáveres).
- **Pila Tecnológica:** Kotlin Multiplatform (KMP), KorGE, Gradle, JVM Desktop.
- **Objetivo Central:** Que los estudiantes pasen de dibujar sprites estáticos en pantalla a dotar al mundo de leyes físicas interactivas (gravedad, fricción, rebote), detección de colisiones optimizada a nivel de bits y un sistema balístico de lanzamiento de hechizos con daño y ciclo de vida de entidades.

---

## 🎯 Objetivos de Aprendizaje (Taxonomía de Bloom)

1. **Comprender (Bitmasks):** Explicar por qué los motores de videojuegos usan operaciones binarias a nivel de bits (`shl`, `or`, `and`) en lugar de colecciones de cadenas o enums para filtrar colisiones a 60 fotogramas por segundo sin sobrecargar el recolector de basura (Garbage Collector).
2. **Aplicar (Geometría 2D & AABB):** Implementar la lógica matemática de cajas alineadas con los ejes (*Axis-Aligned Bounding Box*) y convertir ángulos de disparo a vectores unitarios usando trigonometría (`cos`, `sin`).
3. **Construir (Físicas 2D):** Programar un ciclo de integración de Euler que actualice posiciones en función de la velocidad, aplique aceleración gravitacional descendente y gestione rebotes elásticos y fricción de suelo.
4. **Integrar (Combate Balístico):** Conectar la entrada del usuario (apuntado con ratón) con el lanzamiento de proyectiles con masa y trayectoria parabólica, gestionando el impacto, la aplicación de daño y el ciclo de vida (*spawn* y *despawn*) de las entidades.

---

## 🗺️ Mapa de Arquitectura del Motor (Lección 07)

```
app/shared/src/commonMain/kotlin/.../
├── core/
│   ├── Tags.kt          ← Paso 1: Constantes binarias (1 shl N) y categorías
│   ├── GameObject.kt    ← Paso 1: Entidad base, collisionMask y canCollideWith()
│   ├── Geometry.kt      ← Paso 2: Rect2D (overlaps AABB) y vectorFromAngle()
│   ├── Game.kt          ← Paso 3 & 4: Integración de Euler, rebote y castSpell()
│   └── Damage.kt        ← Sistema de daño desacoplado
├── entities/
│   └── Entities.kt      ← Paso 4: createPlayer(), createSpell(), createVillager()
└── SpriteCombatDemo.kt  ← Bucle interactivo visual en KorGE con ratón y teclado
```

---

## 📽️ Estructura Completa de la Presentación (Diapositiva por Diapositiva)

A continuación se detalla la presentación completa lista para ser explicada en clase o utilizada por NotebookLM para generar diapositivas en Google Slides / PowerPoint.

---

### Diapositiva 1: Portada y Gancho
- **Título:** Lección 07: Físicas 2D, Proyectiles y Combate Balístico
- **Subtítulo:** Dándole vida y leyes físicas al mundo de *Norman The Necromancer*
- **Puntos Clave:**
  - En la Lección 06 aprendimos a cargar sprites y pintarlos en pantalla.
  - Hoy esos sprites dejan de ser imágenes estáticas: interactúan, caen, rebotan y se destruyen.
  - Aprenderemos 4 conceptos que utiliza todo motor profesional (Unity, Godot, Unreal):
    1. Bitmasks para filtrado ultra-rápido.
    2. Cajas AABB para detección geométrica.
    3. Integración de Euler para movimiento y gravedad.
    4. Proyectiles balísticos y callbacks de combate.
- **Notas del Orador (Speaker Notes):**
  > "Bienvenidos a la Lección 7. Hasta hoy, Norman era un personaje dibujado en un lienzo vacío. Si le decíamos que avanzara, simplemente cambiaba su coordenada X o Y. Pero un verdadero videojuego necesita reglas: ¿qué pasa si Norman salta? ¿Qué pasa si lanza un cráneo mágico? ¿Cómo sabe el juego si ese cráneo impactó a un aldeano y no a Norman mismo? Hoy construiremos desde cero la física y el combate del juego."

---

### Diapositiva 2: El Ciclo de Simulación Física (Game Loop & Delta Time)
- **Título:** El Bucle de Juego: ¿Qué pasa en 16.6 milisegundos?
- **Puntos Clave:**
  - Un juego a 60 FPS ejecuta su bucle cada $\approx 16.6$ ms (`dtMs`).
  - **Fórmula de independencia de framerate:**
    $$\Delta t = \frac{\text{dtMs}}{1000.0} \quad (\text{segundos})$$
    $$x_{t+1} = x_t + v_x \cdot \Delta t$$
  - Si una computadora corre a 30 FPS y otra a 120 FPS, el movimiento debe ser idéntico gracias al escalado por `dt`.
  - **Fases del frame físico en Game.kt:**
    1. Fase 1: Movimiento, Gravedad, Restricciones de Escenario (Rebotes y Fricción).
    2. Fase 2: Detección y Resolución de Colisiones entre entidades.
- **Notas del Orador:**
  > "Nunca sumen velocidades directamente a la posición (`x += vx`). Si hacen eso, en un monitor de 144 Hz el personaje se moverá el doble de rápido que en un monitor de 60 Hz. Siempre multiplicamos la velocidad por el tiempo transcurrido en segundos (`d = dtMs / 1000.0`)."

---

### Diapositiva 3: Pilar 1 - Máscaras de Bits (Bitmasks)
- **Título:** Filtrado de Colisiones a Nivel de Bits
- **Puntos Clave:**
  - **El problema:** En un juego con cientos de proyectiles y enemigos, comparar cadenas de texto (`target.tag == "LIVING"`) o colecciones (`target.tags.contains(Tag.LIVING)`) crea miles de objetos temporales y satura el Garbage Collector.
  - **La solución del estándar de la industria:** Números enteros donde cada bit representa una categoría.
  - **Operador de desplazamiento (`1 shl N`):**
    - `CORPSE = 1 shl 0` $\rightarrow 1$ (`000001b`)
    - `LIVING = 1 shl 1` $\rightarrow 2$ (`000010b`)
    - `SPELL  = 1 shl 2` $\rightarrow 4$ (`000100b`)
    - `MOBILE = 1 shl 3` $\rightarrow 8$ (`001000b`)
    - `PLAYER = 1 shl 4` $\rightarrow 16$ (`010000b`)
    - `UNDEAD = 1 shl 5` $\rightarrow 32$ (`100000b`)
  - **Operaciones:**
    - Combinar etiquetas: `Tags.PLAYER or Tags.UNDEAD`
    - Comprobar colisión: `(collisionMask and target.tags) != 0`
- **Código Clave:**
  ```kotlin
  fun canCollideWith(target: GameObject): Boolean {
      return this !== target && (collisionMask and target.tags) != 0
  }
  ```
- **Notas del Orador:**
  > "Fíjense en dos detalles cruciales: primero, `this !== target` evita que un objeto colisione consigo mismo. Segundo, una sola operación lógica `AND` de 32 bits a nivel de CPU resuelve si dos entidades pueden interactuar, ejecutándose en nanosegundos."

---

### Diapositiva 4: Pilar 2 - Detección de Colisiones AABB
- **Título:** Geometría 2D: Axis-Aligned Bounding Box (AABB)
- **Puntos Clave:**
  - Las máscaras de bits filtran *quién puede* chocar. La geometría AABB determina *cuándo* chocan físicamente en el espacio.
  - Una caja AABB no tiene rotación, por lo que la colisión se reduce a verificar si se solapan en ambos ejes a la vez:
    - Eje X: `this.x < other.x + other.width && this.x + this.width > other.x`
    - Eje Y: `this.y < other.y + other.height && this.y + this.height > other.y`
  - **Ventaja:** Solo 4 comparaciones numéricas simples.
- **Diagrama Visual:**
  ```
     [Rectángulo A]
      +----------+
      |          |   [Rectángulo B]
      |     +----+-----+
      |     | // Solape|
      +-----+----+     |
            |          |
            +----------+
  ```
- **Notas del Orador:**
  > "AABB es la primera línea de defensa de todo motor de videojuegos. En lugar de calcular complejas colisiones poligonales o máscaras de píxeles, un AABB descarta el 99% de los casos lejanos en microsegundos."

---

### Diapositiva 5: Pilar 2 (Cont.) - Trigonometría y Apuntado con el Ratón
- **Título:** De la Pantalla al Ángulo: Trigonometría en Videojuegos
- **Puntos Clave:**
  - El jugador apunta con el cursor del ratón. ¿Cómo sabemos en qué dirección viaja el proyectil?
  - **Paso 1: Ángulo relativo con Arcangente 2 (`atan2`):**
    $$\theta = \text{atan2}(\Delta y, \Delta x) = \text{atan2}(\text{mouse}_y - \text{player}_y, \, \text{mouse}_x - \text{player}_x)$$
  - **Paso 2: Conversión a Vector Unitario:**
    $$\vec{v} = (\cos(\theta), \, \sin(\theta))$$
  - **Paso 3: Escalado por la potencia del disparo:**
    $$v_x = \cos(\theta) \cdot \text{basePower}$$
    $$v_y = \sin(\theta) \cdot \text{basePower}$$
- **Notas del Orador:**
  > "¿Por qué usamos `atan2` en vez de `atan`? Porque `atan2(y, x)` toma en cuenta los signos de ambos ejes y maneja los 4 cuadrantes completos (de $-\pi$ a $+\pi$) sin causar divisiones por cero cuando $\Delta x = 0$."

---

### Diapositiva 6: Pilar 3 - Motor de Físicas 2D por Integración de Euler
- **Título:** Simulando la Realidad: Velocidad, Gravedad, Rebote y Fricción
- **Puntos Clave:**
  - **1. Integración de Posición:**
    ```kotlin
    obj.x += obj.vx * d
    obj.y += obj.vy * d
    ```
  - **2. Aceleración Gravitacional:**
    Si el objeto tiene masa y está sobre el suelo (`y > 0`):
    ```kotlin
    if (obj.mass > 0 && obj.y > 0) {
        obj.vy -= obj.mass * d
    }
    ```
  - **3. Restricción de Suelo y Rebote:**
    Si choca contra el suelo (`y < floor`), se reposiciona en el suelo y se invierte su velocidad vertical atenuada por su coeficiente de restitución:
    ```kotlin
    obj.y = clamp(obj.y, stage.floor, stage.ceiling - obj.spriteHeight)
    obj.vy *= -obj.bounce
    ```
  - **4. Fricción Horizontal en Suelo:**
    ```kotlin
    obj.vx *= (1.0 - obj.friction)
    ```
- **Notas del Orador:**
  > "Este algoritmo es la Integración de Euler explícita. Es simple, intuitivo y extremadamente eficiente para juegos arcade en 2D. Observen cómo la masa aquí actúa como la aceleración de la gravedad hacia abajo."

---

### Diapositiva 7: Pilar 4 - Hechizos Balísticos y Trayectoria Parabólica
- **Título:** Balística Mágica: El Hechizo de Norman
- **Puntos Clave:**
  - Norman dispara una calavera mágica (`spell_skull`).
  - Al combinar velocidad inicial angular hacia arriba ($v_y > 0$) con gravedad continua ($v_y$ disminuye en cada frame), se produce naturalmente una **trayectoria parabólica**.
  - **Gestión de Recursos (`SpellState`):**
    - Cargas máximas: 3
    - Tiempo de recarga: 1 segundo (`1000.0` ms) por carga.
    - Se consume 1 carga al disparar; si `casts == 0`, no se puede disparar.
- **Código en `castSpell()`:**
  ```kotlin
  if (spell.casts <= 0) return false
  spell.casts--
  val p = createSpell()
  val dir = vectorFromAngle(spell.targetAngle)
  p.vx = dir.x * spell.basePower
  p.vy = dir.y * spell.basePower
  spawn(p, player.x + player.spriteWidth / 2.0, player.y + player.spriteHeight / 2.0)
  return true
  ```
- **Notas del Orador:**
  > "Observen la elegancia del diseño: no necesitamos una fórmula compleja para dibujar parábolas. La parábola es una propiedad emergente de sumar velocidad y aplicar gravedad frame a frame."

---

### Diapositiva 8: Pilar 4 (Cont.) - Sistema de Daño y Ciclo de Vida
- **Título:** Impacto, Daño y Despawn: El Ciclo de Vida
- **Puntos Clave:**
  - Cuando el proyectil toca a un aldeano:
    1. Se detecta colisión: `canCollideWith()` da `true` y `bounds().overlaps()` da `true`.
    2. Se invoca el callback: `spell.onCollision(villager)`.
    3. Se aplica el daño: `gameSession.damage(target, amount = 1)`.
    4. Se destruye el proyectil: `despawnOnCollision = true`.
    5. Si la salud del aldeano llega a 0 (`hp <= 0`), la entidad muere y se remueve del escenario.
  - En la siguiente lección (L08), en lugar de desaparecer, ¡el aldeano dejará un cadáver (`CORPSE`) que Norman podrá revivir!
- **Diagrama de Ciclo de Vida:**
  ```
  [Norman dispara] ──> [Spawn Hechizo] ──> [Físicas / Parábola]
                                                  │
                                                  ▼
  [Aldeano Muere / Despawn] <── [Daño HP - 1] <── [Colisión AABB]
  ```
- **Notas del Orador:**
  > "Fíjense cómo desacoplamos responsabilidades: el proyectil no modifica directamente la vida del enemigo, sino que llama a `gameSession.damage()`. Esto permite que más adelante podamos añadir escudos, armaduras o efectos de sonido sin tocar la entidad proyectil."

---

### Diapositiva 9: Demostración Interactiva en Vivo
- **Título:** Live Demo: Norman en Acción en Desktop
- **Puntos Clave:**
  - Ejecutar el proyecto en Desktop:
    ```bash
    task desktop
    # o directamente con Gradle:
    cd app && ./gradlew :desktopApp:run
    ```
  - **Controles de la Demo:**
    - Mover el ratón: La mira angular recalcula la trayectoria en tiempo real.
    - Clic izquierdo / Barra espaciadora: Disparar calavera mágica.
    - Observar en vivo el rebote en el suelo y la pérdida de velocidad por fricción.
    - Ver a los 3 aldeanos recibir impactos y desaparecer cuando sus HP bajan a 0.
- **Validación Automática con Tests:**
  ```bash
  task test
  # o con Gradle:
  cd app && ./gradlew :shared:jvmTest
  ```
- **Notas del Orador:**
  > "Invitamos a los alumnos a clonar el repositorio, ejecutar la demo y experimentar cambiando valores: ¿qué pasa si aumentamos la gravedad? ¿Qué pasa si cambiamos el rebote a 0.9? ¿Qué pasa si aumentamos la fricción?"

---

### Diapositiva 10: Conclusiones y Próximos Pasos (Hacia la Lección 08)
- **Título:** Resumen y Lo Que Viene: ¡Nigromancia!
- **Puntos Clave:**
  - **Lo que logramos hoy:**
    - ✅ Máscaras de bits para filtrado eficiente $O(1)$.
    - ✅ Detección geométrica AABB y vectores angulares.
    - ✅ Motor de físicas con integración de Euler, rebotes y fricción.
    - ✅ Sistema balístico completo con disparo, impacto y daño.
  - **Próxima parada (Lección 08):**
    - Los aldeanos caídos ya no se destruirán: se convertirán en entidades `CORPSE`.
    - Norman podrá canalizar su magia oscura para revivirlos como aliados `UNDEAD`.
    - Construcción de IA de hordas que ataquen a otros enemigos vivos.
- **Notas del Orador:**
  > "¡Felicidades! Han construido los cimientos de cualquier motor de físicas en 2D. En la siguiente clase, combinaremos las máscaras de bits que creamos hoy con la mecánica insignia de Norman: convertir cadáveres en un ejército no muerto."

---

## ❓ Preguntas Frecuentes y Casos Límite para el Aula (FAQ)

Ideal para generar sesiones de preguntas y respuestas en clase o para el **Audio Overview** de NotebookLM:

1. **¿Por qué usamos `dt` en segundos y no directamente los milisegundos?**
   - *Respuesta:* Porque las unidades de física se expresan en unidades por segundo (por ejemplo, velocidad en píxeles por segundo: $50 \text{ px/s}$, o gravedad en píxeles por segundo al cuadrado: $200 \text{ px/s}^2$). Si multiplicáramos por milisegundos, los números escalarían de forma astronómica en cada frame.

2. **¿Qué es el problema del "túnel" (*Tunneling*) en colisiones?**
   - *Respuesta:* Si un proyectil viaja a 3000 px/s y un frame dura 16 ms, el proyectil avanza 48 píxeles en un solo salto. Si el enemigo mide 20 píxeles de ancho, el proyectil podría estar antes del enemigo en el frame $N$ y después del enemigo en el frame $N+1$, sin haber tocado nunca su caja AABB. Para juegos rápidos se usa *Continuous Collision Detection* (CCD) o raymarching; pero para la velocidad de nuestro hechizo (380 px/s), AABB discreto es perfecto.

3. **¿Por qué `1 shl N` y no números directos como 1, 2, 4, 8?**
   - *Respuesta:* Es idéntico en valor, pero `1 shl N` (1 shifted left N) comunica claramente el índice del bit en la memoria (bit 0, bit 1, bit 2...) y evita errores humanos al escribir potencias de 2 en categorías elevadas (e.g., bit 15 = 32768).

4. **¿Por qué la condición AABB usa desigualdades estrictas (`<` y `>`)?**
   - *Respuesta:* Porque si dos cajas solo comparten el borde exacto (e.g. una termina en $x=10$ y la otra empieza en $x=10$), no se están penetrando; están adyacentes.

---

## 🚀 Guía de Uso en Google NotebookLM

Sigue estos sencillos pasos para crear tu presentación y materiales interactivos con **Google NotebookLM**:

### Paso 1: Acceder a NotebookLM
1. Ingresa a [notebooklm.google.com](https://notebooklm.google.com/).
2. Haz clic en **"Nueva libreta"** (o *New Notebook*).
3. Nómbrala: **"Lección 07 - Físicas 2D y Combate Balístico"**.

### Paso 2: Subir esta Fuente
1. Selecciona la opción **Subir fuentes** (*Add sources*).
2. Elige **"Archivo local"** (*Upload file*) y sube el archivo `LECCION_07_PRESENTACION_NOTEBOOKLM.md` (o copia y pega su contenido directamente si prefieres la opción de texto).

### Paso 3: Generar el "Audio Overview" (Podcast de la Lección)
1. En la parte superior derecha de NotebookLM, verás la tarjeta **"Resumen de audio"** (*Audio Overview / Deep Dive*).
2. Haz clic en **Generar** (*Generate*).
3. ¡Dos presentadores de IA tendrán una conversación de 8 a 12 minutos explicando las físicas de Norman, el uso de las bitmasks, las parábolas y los conceptos clave con un tono educativo y dinámico!

### Paso 4: Prompts Sugeridos para Chatear con la Libreta

Copia y pega cualquiera de estos prompts en el chat de NotebookLM:

#### Para Diapositivas en Google Slides o PowerPoint:
> *"A partir del documento de la Lección 07, formatea una presentación de 10 diapositivas para Google Slides. Para cada diapositiva proporciona: Título, 3 viñetas concisas y de alto impacto, el fragmento de código relevante, y notas para el profesor."*

#### Para una Guía de Estudio / Hoja de Referencia rápida:
> *"Genera una 'Cheat Sheet' de una sola página en Markdown con todas las fórmulas matemáticas y operadores binarios explicados en esta lección (Euler, AABB, trigonometría y bitmasks)."*

#### Para un Examen Corto / Quiz interactivo:
> *"Crea un quiz de 5 preguntas de opción múltiple para evaluar a los alumnos al final de la clase. Incluye la justificación de la respuesta correcta basada en el texto fuente."*

#### Para el Guión del Profesor (Live Coding):
> *"Dame un guión de Live Coding paso a paso de 30 minutos para que el profesor vaya programando junto con los alumnos los 4 pasos del ejercicio sin perderse."*
