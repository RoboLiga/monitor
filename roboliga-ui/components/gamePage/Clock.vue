<template>
    <div class="clock myFont text-center" :class="{'clock--ending': isEnding}">
        {{ formatted }}
    </div>
</template>

<script setup>
const props = defineProps(['timeLeft'])

const seconds = computed(() => Math.max(0, Math.ceil(props.timeLeft)))

const isEnding = computed(() => seconds.value > 0 && seconds.value <= 10)

const formatted = computed(() => {
    const minutes = Math.floor(seconds.value / 60);
    const secs = seconds.value % 60;
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
})
</script>

<style scoped>
.clock {
    font-size: clamp(2rem, 5vw, 5rem);
    line-height: 1;
    font-weight: 600;
    font-variant-numeric: tabular-nums;
    color: #757575 !important;
}

.clock--ending {
    color: #c62828 !important;
    animation: pulse 1s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% {
        opacity: 1;
        transform: scale(1);
    }
    50% {
        opacity: 0.7;
        transform: scale(1.08);
    }
}

@media (prefers-reduced-motion: reduce) {
    .clock--ending {
        animation: none;
    }
}
</style>
