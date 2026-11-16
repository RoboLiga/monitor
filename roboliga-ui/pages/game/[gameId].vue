<template>
    <v-container fluid class="ma-0 pa-0">
        <v-row justify="center" align="center">

            <v-btn style="position: absolute; left: 0;" icon="mdi-arrow-left" variant="plain"
                   color="primary" size="x-large" density="compact" :ripple="false" @click="navigateTo('/')"></v-btn>

            <ControlPanel :game_on="gameState.game_on" :game_paused="gameState.game_paused"
                          :teamsId="[teamBlueId,teamRedId]" :showCoordinates="showCoordinates" 
                          @update:showCoordinates="showCoordinates = $event" 
                          @gameStateChange="handleGameStateChange"
                          @update:game_paused="gameState.game_paused = $event"></ControlPanel>
        </v-row>

        <v-row justify="center" align="stretch" no-gutters class="px-4 py-2">
            <v-col cols="5" md="5">
                <Score v-if="gameState.teams[teamBlueId]" orientation="left" :team="gameState.teams[teamBlueId]"/>
            </v-col>
            <v-col cols="2" md="2" class="d-flex align-center justify-center">
                <Clock :time-left="gameState.time_left"></Clock>
            </v-col>
            <v-col cols="5" md="5">
                <Score v-if="gameState.teams[teamRedId]" orientation="right" :team="gameState.teams[teamRedId]"/>
            </v-col>

        </v-row>

        <v-row justify="center" align="center">
            <v-col cols="10">
                <div ref="canvasDiv" class="text-center">
                    <MyCanvas :gameState="gameState" :canvasWidth="canvasWidth" :showCoordinates="showCoordinates" :game_paused="gameState.game_paused" :game_on="gameState.game_on" :objectTypes="objectTypes" :delay="gameState.delay"/>
                </div>
            </v-col>
        </v-row>
    </v-container>
</template>

<script setup>
import ControlPanel from "~/components/gamePage/ControlPanel.vue";
import Clock from "~/components/gamePage/Clock.vue";
import Score from "~/components/gamePage/Score.vue";
import MyCanvas from "~/components/gamePage/MyCanvas.vue";
import {navigateTo} from "#app";
import { useAuthStore } from "~/stores/auth";
import { getSideTeamIds } from "~/utils/teams";

const {gameId} = useRoute().params
const baseApiUrl = useRuntimeConfig().public.baseApiUrl
const auth = useAuthStore();
const { $promptPassword } = useNuxtApp();

const {data: gameState, refresh} = await useFetch(baseApiUrl + `/game/${gameId}`, {
    method: 'GET',
})

if (!gameState.value) {
    throw createError({statusCode: 404, statusMessage: 'Game does not exist!', fatal: true})
}

let objectTypes = ref(null);

const fetchObjectTypes = async () => {
  const password = auth.getPass(gameId);
  const { data, error } = await useFetch(baseApiUrl + `/game/objects`, {
    method: "GET",
    headers: {
      Authorization: "Basic " + btoa(`${gameId}:${password}`),
    },
  });

  if (error.value) {
    const errorMessage = error.value.message || error.value.toString();
    const statusMatch = errorMessage.match(/: (\d{3}) /);
    const status = statusMatch ? parseInt(statusMatch[1], 10) : null;
    if (status === 401) {
        console.error("You do not own this game - object types are unavailable.");
    }
  } else {
    objectTypes.value = data.value;
  }
};

await fetchObjectTypes();

// "Blue" is the left team and "red" the right team, whatever colors the game uses
const [initialBlueId, initialRedId] = getSideTeamIds(gameState.value.teams)
const teamBlueId = ref(initialBlueId)
const teamRedId = ref(initialRedId)

const updateTeams = () => {
    [teamBlueId.value, teamRedId.value] = getSideTeamIds(gameState.value.teams)
}

const canvasDiv = ref(null)
let canvasWidth = ref(600)
let showCoordinates = ref(false)

let intervalId;

const setRefreshInterval = () => {
    clearInterval(intervalId);
    const intervalTime = gameState.value.game_on ? 20 : 1000;
    intervalId = setInterval(() => {
        canvasWidth.value = canvasDiv.value.clientWidth
        canvasWidth.value = Math.min(canvasWidth.value, window.innerHeight)
        refresh()
        updateTeams()
    }, intervalTime);

    // Immediately refresh and update teams
    canvasWidth.value = canvasDiv.value.clientWidth
    canvasWidth.value = Math.min(canvasWidth.value, window.innerHeight)
    refresh()
    updateTeams()
}

const handleGameStateChange = (isGameOn) => {
    gameState.value.game_on = isGameOn;
    if (isGameOn) {
        gameState.value.game_paused = false;
    }
    setRefreshInterval();
}

onMounted(() => {
    setRefreshInterval();
})

watch(() => gameState.value.game_on, () => {
    setRefreshInterval();
})

watch(() => gameState.value.time_left, (newTimeLeft) => {
    gameState.value.time_left = newTimeLeft;
})

onUnmounted(() => {
    clearInterval(intervalId)
})

</script>