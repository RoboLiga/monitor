<template>
    <v-container>
        <v-row :justify="scoreField.justify" align="center">
            <v-col cols="9" md="9" lg="10" :order="scoreField.order1">
                <div class="text-h5 text-md-h3 myFont" style="word-break: break-word" :class="scoreField.text">{{team.name }}</div>
            </v-col>
            <v-col cols="3" md="3" lg="2" :order="scoreField.order2">
                <div class="text-h5 text-md-h1 myFont" :class="scoreField.text">{{ team.score }}</div>
            </v-col>
        </v-row>
        <v-row justify="center" align="center">
            <v-col cols="10">
                <v-progress-linear
                        v-if="hasFuel"
                        :indeterminate="team.charging && fuelPercent < 98"
                        :model-value="fuelPercent"
                        :color="scoreField.color"
                        :reverse="scoreField.progress">
                </v-progress-linear>

            </v-col>
        </v-row>
    </v-container>
</template>

<script>
export default {
    name: "Score",
    props: ["orientation", "team", "maxFuel"],
    setup(props) {

        /*const def_team = {
            "id": 0,
            "color": "red",
            "name": "Placeholder",
            "score": 0,
            "fuel": 25,
            "charging": true
        }*/

        const team = ref(props.team)

        // Not every game has fuel (e.g. Construction)
        const hasFuel = computed(() => {
            return team.value.fuel !== undefined && !!props.maxFuel
        })

        const fuelPercent = computed(() => {
             return team.value.fuel / props.maxFuel * 100
        })

        const scoreField = computed(() => {
            const color = team.value.color || (props.orientation === 'left' ? 'blue' : 'red')

            const left = {
                order1: 0,
                order2: 1,
                color: `${color}-lighten-2`,
                text: `text-${color}-lighten-1 text-right`,
                justify: "end",
                progress: true
            }

            const right = {
                order1: 1,
                order2: 0,
                color: `${color}-lighten-2`,
                text: `text-${color}-lighten-1 text-left`,
                justify: "start",
                progress: false
            }
            return props.orientation === 'left' ? left : right
        })



        return {hasFuel, fuelPercent, scoreField, team}
    },




}
</script>

<style scoped>

</style>