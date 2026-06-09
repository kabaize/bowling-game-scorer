/* Generates a valid, complete 10-frame bowling game.
* Rolls: "X", "/", or 0–9.
*/

export function generateRandomCompleteGameRolls() {
    const rolls = [];

    // Frames 1–9
    for (let frame = 1; frame <= 9; frame++) {
        const firstRoll = getRandomInteger(0, 10);

        if (firstRoll === 10) {
            rolls.push("X");
            continue;
        }

        rolls.push(firstRoll);

        const remainingPins = 10 - firstRoll;
        const secondRoll = getRandomInteger(0, remainingPins);

        if (secondRoll === remainingPins) {
            rolls.push("/");
        } else {
            rolls.push(secondRoll);
        }
    }

    // Frame 10
    const firstRollTenthFrame = getRandomInteger(0, 10);

    if (firstRollTenthFrame === 10) {
        rolls.push("X");

        const firstBonusRoll = getRandomInteger(0, 10);
        rolls.push(firstBonusRoll === 10 ? "X" : firstBonusRoll);

        if (firstBonusRoll === 10) {
            const bonus2 = getRandomInteger(0, 10);
            rolls.push(bonus2 === 10 ? "X" : bonus2);
        } else {
            const secondBonusRoll = getRandomInteger(0, 10 - firstBonusRoll);
            rolls.push(secondBonusRoll);
        }

        return rolls;
    }

    rolls.push(firstRollTenthFrame);

    const remaining = 10 - firstRollTenthFrame;
    const secondRollTenthFrame = getRandomInteger(0, remaining);

    if (secondRollTenthFrame === remaining) {
        rolls.push("/");

        const bonus = getRandomInteger(0, 10);
        rolls.push(bonus === 10 ? "X" : bonus);
    } else {
        rolls.push(secondRollTenthFrame);
    }

    return rolls;
}

export function rollsToString(rolls) {
    return rolls.join(",");
}

function getRandomInteger(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
