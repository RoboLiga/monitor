// Games use different team colors (Beach: blue/red, Construction: orange/green),
// so each side of the monitor accepts any of these colors
const LEFT_COLORS = ['blue', 'orange']
const RIGHT_COLORS = ['red', 'green']

// Returns [leftTeamId, rightTeamId]; teams with unknown colors fill any empty side
export const getSideTeamIds = (teams) => {
    const allTeams = Object.values(teams || {})
    const left = allTeams.find(t => LEFT_COLORS.includes(t.color))
    const right = allTeams.find(t => RIGHT_COLORS.includes(t.color) && t !== left)
    const rest = allTeams.filter(t => t !== left && t !== right)

    return [
        (left ?? rest.shift())?.id ?? 0,
        (right ?? rest.shift())?.id ?? 0
    ]
}
