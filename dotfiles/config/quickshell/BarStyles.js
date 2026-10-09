.pragma library


function geometry(name, barHeight, bgA) {
    switch (name) {
    case "floating":
        return { file: "02", height: 48, color: "transparent", exclusive: 38, top: true, bottom: false, clock: "center" };
    case "flat":
        return { file: "03", height: 28, color: bgA, exclusive: 28, top: true, bottom: false, clock: "center" };
    case "pill":
        return { file: "04", height: 54, color: "transparent", exclusive: 46, top: true, bottom: false, clock: "center" };
    case "capsule":
        return { file: "05", height: 50, color: "transparent", exclusive: 42, top: true, bottom: false, clock: "center" };
    case "bottom":
        return { file: "06", height: 48, color: "transparent", exclusive: 40, top: false, bottom: true, clock: "center" };
    case "split":
        return { file: "07", height: 56, color: "transparent", exclusive: 38, top: true, bottom: false, clock: "right" };
    case "blocky":
        return { file: "08", height: 34, color: bgA, exclusive: 34, top: true, bottom: false, clock: "center" };
    case "ghost":
        return { file: "09", height: 48, color: "transparent", exclusive: 38, top: true, bottom: false, clock: "center" };
    case "minipills":
        return { file: "10", height: 50, color: "transparent", exclusive: 38, top: true, bottom: false, clock: "center" };
    case "noir":
        // Six pills on a clear bar: launcher, workspaces, clock, apps, status, power.
        return { file: "11", height: 36, color: "transparent", exclusive: 36, top: true, bottom: false, clock: "center" };
    default:
        return { file: "01", height: barHeight, color: bgA, exclusive: barHeight, top: true, bottom: false, clock: "center" };
    }
}
