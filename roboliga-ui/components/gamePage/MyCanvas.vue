<template>
    <canvas ref="myCanvas" :width="size.w" :height="size.h" @click="handleCanvasClick" @mousemove="handleMouseMove"></canvas>
    <div v-if="showCoordinates && hoverCoordinates" class="coordinates" :style="{ top: hoverCoordinates.y + 'px', left: hoverCoordinates.x + 'px' }">
        {{ hoverCoordinates.text }}
    </div>
    <slot></slot>
</template>

<script setup>
const props = defineProps(['gameState', 'canvasWidth', 'showCoordinates', 'game_paused', 'game_on', 'objectTypes', 'delay'])
import config from "~/config.json"

const myCanvas = ref(null);
const hoverCoordinates = ref(null);

let size = reactive({
    w: 0,
    h: 0,
    scale: 1
})

let cubeColors = reactive({});

const objectTypeColors = {
    plastic: 'red',
    glass: 'green',
    shells: '#1565C0',
    cherry: '#E91E63',
    pine: '#1B5E20',
    steel: '#78909C',
    brick: '#B23A1E'
}

// Some games send objects flat ({id: object}), others grouped by type ({type: {id: object}})
const flatObjects = computed(() => {
    const result = {}
    for (const [key, value] of Object.entries(props.gameState.objects || {})) {
        if (value && value.position)
            result[key] = value
        else
            Object.assign(result, value)
    }
    return result
})

const objectColor = (key) => {
    const type = props.objectTypes ? props.objectTypes[key] : null
    return cubeColors[key] || objectTypeColors[type] || config.field_colors.undefined
}

let setSize = () => {
    const maxW = props.gameState.fields.game_field.bottom_right.x
    const maxH = props.gameState.fields.game_field.bottom_right.y

    size.w = props.canvasWidth
    size.h = size.w / 1.71
    size.scale = size.w / maxW

    manager.setSize(size)
}

watch(() => props.canvasWidth, () => {
    setSize()
    draw()
})

watch(() => props.gameState, () => {
    draw()
}, {deep: true})

function CanvasManager(w, h) {
    this.w = w;
    this.h = h;
    this.scale = 1;
    this.ctx = null;
    this.colors = config.field_colors

    this.setContext = function (ctx) {
        this.ctx = ctx;
    }
    this.setSize = function (size) {
        this.w = size.w;
        this.h = size.h;
        this.scale = size.scale
    }

    this.clearField = () => {
        this.ctx.clearRect(0, 0, this.w, this.h);
    }

    this.drawField = (key) => {
        const field = props.gameState.fields[key]
        const context = this.ctx
        const scale = this.scale;

        context.save();
        context.beginPath();
        context.moveTo(field.top_left.x * scale, field.top_left.y * scale);
        context.lineTo(field.top_right.x * scale, field.top_right.y * scale);
        context.lineTo(field.bottom_right.x * scale, field.bottom_right.y * scale);
        context.lineTo(field.bottom_left.x * scale, field.bottom_left.y * scale);
        context.closePath();
        context.strokeStyle = this.colors[key] || this.colors.undefined;
        context.stroke()

        if (key !== 'game_field') {
            context.fillStyle = this.colors[key] || this.colors.undefined;
            context.fill()
        }

        // Restore the canvas context state
        context.restore();
    }

    this.drawCube = (key) => {
        const cube = flatObjects.value[key]
        const context = this.ctx;
        const scale = this.scale;
        // Save the canvas context state, so we can restore it later
        context.save();
        // Set the cube color based on its type
        context.fillStyle = objectColor(key);
        // Translate the canvas context to the center of the cube
        context.translate(cube.position.x * scale, cube.position.y * scale);
        // Rotate the canvas context by the cube's direction in degrees
        context.rotate(cube.dir * Math.PI / 180);
        // Draw the cube
        context.fillRect(-75 * scale, -75 * scale, 150 * scale, 150 * scale);
        // Draw border around the cube
        context.strokeStyle = 'black';
        context.lineWidth = 1;
        context.strokeRect(-75 * scale, -75 * scale, 150 * scale, 150 * scale);
        // Restore the canvas context state
        context.restore();
    }
    this.drawRobot = (key) => {
    const robot = props.gameState.robots[key]

    const context = this.ctx;
    const scale = this.scale;

    const {x, y} = robot.position
    const dir = robot.dir
    const shorterLength = 150 * scale
    const longerLength = 270 * scale

    // Save the canvas context state, so we can restore it later
    context.save();
    // Set the robot color
    context.fillStyle = props.gameState.teams[key] && props.gameState.teams[key].color || this.colors.box;

    context.translate(x * scale, y * scale)
    context.rotate(((dir - 90) * Math.PI) / 180)
    context.beginPath()
    context.moveTo(-shorterLength / 2, longerLength / 3)
    context.lineTo(shorterLength / 2, longerLength / 3)
    context.lineTo(longerLength / 2, -longerLength / 3)
    context.lineTo(-longerLength / 2, -longerLength / 3)
    context.closePath()
    context.fill()

    // Restore the canvas context state
    context.restore();

    if (props.showCoordinates) {
        context.save();
        context.fillStyle = 'black';
        context.font = '12px Arial';
        context.fillText(`Dir: ${dir.toFixed(4)}`, (x + 10) * scale, (y - 10) * scale); // Round to two decimal places in the text
        context.restore();
    }
}
}

let manager = new CanvasManager(size.w, size.h);

function draw() {
    manager.clearField()

    for (let key in props.gameState.fields) {
        if (key !== config.field_key)
            manager.drawField(key);
    }
    manager.drawField(config.field_key)

    for (let key in flatObjects.value) {
        manager.drawCube(key);
    }

    for (let key in props.gameState.robots) {
        manager.drawRobot(key);
    }

    if (props.game_on && props.game_paused) {
        drawPausedText();
    }

    if (props.showCoordinates) {
        drawDelay();
    }
}

function handleCanvasClick(event) {
    const rect = myCanvas.value.getBoundingClientRect();
    const x = (event.clientX - rect.left) / size.scale;
    const y = (event.clientY - rect.top) / size.scale;

    for (let key in flatObjects.value) {
        const cube = flatObjects.value[key];
        if (x >= cube.position.x - 50 && x <= cube.position.x + 50 &&
            y >= cube.position.y - 50 && y <= cube.position.y + 50) {
                //toggleCubeColor(key);
                //draw();
                break;
        }
    }
}

function toggleCubeColor(key) {
    const colors = ['red', 'green', '#1565C0'];
    const currentColor = cubeColors[key] || config.field_colors.undefined;
    const currentIndex = colors.indexOf(currentColor);
    const nextIndex = (currentIndex + 1) % colors.length;
    cubeColors[key] = colors[nextIndex];
}

function handleMouseMove(event) {
    const rect = myCanvas.value.getBoundingClientRect();
    const x = Math.round((event.clientX - rect.left) / size.scale);
    const y = Math.round((event.clientY - rect.top) / size.scale);

    hoverCoordinates.value = {
        x: event.clientX,
        y: event.clientY,
        text: `X: ${x}, Y: ${y}`
    };
}

function drawPausedText() {
    const context = manager.ctx;
    context.save();
    context.font = 'bold 48px Arial';
    context.fillStyle = 'rgba(255, 0, 0, 0.7)';
    context.textAlign = 'center';
    context.fillText('Game Paused', manager.w / 2, manager.h / 2);
    context.restore();
}

function drawDelay() {
    const context = manager.ctx;
    context.save();
    context.font = '12px Arial';
    context.fillStyle = 'black';
    context.textAlign = 'left';
    context.fillText(`Delay: ${props.delay}`, 10, manager.h - 10);
    context.restore();
}

onMounted(() => {
    manager.setContext(myCanvas.value.getContext('2d'));
    draw();
});
onUpdated(() => {
    draw();
});
</script>

<style scoped>
.coordinates {
    position: absolute;
    padding: 5px;
    pointer-events: none;
}
</style>