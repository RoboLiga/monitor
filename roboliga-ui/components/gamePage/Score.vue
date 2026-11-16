<template>
    <div class="score-card myFont" :class="orientation === 'left' ? 'score-card--left' : 'score-card--right'"
         :style="cardStyle">
        <div class="team-name">{{ team.name }}</div>

        <div class="score-wrap">
            <div class="deltas">
                <span v-for="d in deltas" :key="d.id" class="delta"
                      :class="d.value > 0 ? 'delta--up' : 'delta--down'">
                    {{ d.value > 0 ? '+' : '' }}{{ d.value }}
                </span>
            </div>
            <span class="score-value">{{ team.score }}</span>
        </div>
    </div>
</template>

<script setup>
import colors from "vuetify/util/colors";

const props = defineProps(['orientation', 'team'])

const DELTA_DURATION = 1400

const palette = computed(() => {
    const name = props.team.color || (props.orientation === 'left' ? 'blue' : 'red')
    return colors[name] || colors.grey
})

const cardStyle = computed(() => ({
    '--team-accent': palette.value.base,
    '--team-bg': palette.value.lighten5,
    '--team-text': palette.value.darken2,
}))

// Floating "+N" / "-N" whenever the score changes
const deltas = ref([])
const timeouts = new Set()
let nextId = 0

watch(() => [props.team.id, props.team.score], ([newTeam, newScore], [oldTeam, oldScore]) => {
    // A different team on this side is not a score change
    if (newTeam !== oldTeam) {
        deltas.value = []
        return
    }
    if (newScore === oldScore) return
    const id = nextId++
    deltas.value.push({id, value: newScore - oldScore})
    const t = setTimeout(() => {
        deltas.value = deltas.value.filter(d => d.id !== id)
        timeouts.delete(t)
    }, DELTA_DURATION)
    timeouts.add(t)
})

onUnmounted(() => {
    timeouts.forEach(clearTimeout)
})
</script>

<style scoped>
.score-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    height: 100%;
    padding: 0.75rem 1.5rem;
    border-radius: 16px;
    background: var(--team-bg);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.score-card--left {
    border-left: 10px solid var(--team-accent);
}

/* Right card mirrors the left: score faces the clock, name faces outward */
.score-card--right {
    flex-direction: row-reverse;
    border-right: 10px solid var(--team-accent);
}

.team-name {
    font-size: clamp(1.75rem, 3.6vw, 3.75rem);
    line-height: 1.15;
    font-weight: 600;
    color: var(--team-text) !important;
    word-break: break-word;
    min-width: 0;
}

.score-card--left .team-name {
    text-align: left;
}

.score-card--right .team-name {
    text-align: right;
}

/* Score with its change indicator beside it, on the side facing the team name */
.score-wrap {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    flex-shrink: 0;
}

.score-card--right .score-wrap {
    flex-direction: row-reverse;
}

.score-value {
    display: block;
    font-size: clamp(3rem, 9vw, 9rem);
    line-height: 1;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
    color: var(--team-text);
}

.deltas {
    position: relative;
    align-self: stretch;
    width: clamp(3rem, 6vw, 6rem);
    pointer-events: none;
}

.delta {
    position: absolute;
    top: 50%;
    font-size: clamp(1.5rem, 3.6vw, 3.6rem);
    font-weight: 700;
    line-height: 1;
    white-space: nowrap;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8);
    animation: float-up 1.4s ease-out forwards;
}

/* Hug the number */
.score-card--left .delta {
    right: 0;
}

.score-card--right .delta {
    left: 0;
}

.delta--up {
    color: #2e7d32;
}

.delta--down {
    color: #c62828;
}

@keyframes float-up {
    0% {
        opacity: 0;
        transform: translateY(-50%) scale(0.8);
    }
    15% {
        opacity: 1;
        transform: translateY(-60%) scale(1.15);
    }
    100% {
        opacity: 0;
        transform: translateY(-150%) scale(1);
    }
}

@media (prefers-reduced-motion: reduce) {
    .delta {
        animation: fade-out 1.4s ease-out forwards;
    }

    @keyframes fade-out {
        0%, 30% {
            opacity: 1;
            transform: translateY(-50%);
        }
        100% {
            opacity: 0;
            transform: translateY(-50%);
        }
    }
}
</style>
