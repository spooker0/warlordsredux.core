addEventListener("error", (event) => {
    A3API.SendAlert(`["error", "${event.message}"]`);
});