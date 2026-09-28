<p align="center">
  <img src="assets/logo.png" alt="Elite Development" width="220">
</p>

<h1 align="center">🐴 Horse Ranch</h1>

<p align="center">
  <b>A standalone RedM resource to buy, breed, train and sell horses from a vintage stable-ledger UI.</b><br>
  Developed by <b>Elite Development</b>
</p>

<p align="center">
  <img alt="RedM" src="https://img.shields.io/badge/RedM-resource-b22222">
  <img alt="Lua" src="https://img.shields.io/badge/Lua-5.4-2C2D72">
  <img alt="Version" src="https://img.shields.io/badge/version-1.0.0-4a6e2e">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-lightgrey">
</p>

---

## ✨ Features

- **Stable ledger UI** – an old-west, paper-and-ink styled ledger with three tabs: *My Horses*, *Buy* and *Breed*.
- **Buy horses** – four starter breeds (Kentucky Saddler, Missouri Fox Trotter, Thoroughbred, Andalusian). Every horse rolls its own stats, so no two are the same.
- **Stats system** – each horse has **Speed**, **Stamina** and **Temperament** (0–100) plus a **Condition** meter.
- **Training mini-game** – tap to work the horse for 5 seconds; better performance means bigger stat gains. Training costs condition and has a cooldown.
- **Breeding** – pick two horses you own and pay a fee to produce a foal with averaged, randomized stats.
- **Selling** – sell price is based on a horse's average stats, so well-bred and well-trained horses are worth much more.
- **Passive recovery** – condition slowly recovers over time.
- **Saves automatically** – horse data is stored in `server/horses.json`. No database needed.
- **Standalone by default** – works out of the box with a built-in wallet, with a money bridge you can hook into your framework.

## 🎬 Live demo

<a href="[https://elite-development-services.github.io/ELiTE-saloon-poker/](https://elite-development-services.github.io/EliteDeve-horse-ranch/)"> <img src="https://img.shields.io/badge/🎬%20LIVE%20DEMO-Play%20Now-8B4513?style=for-the-badge" alt="Live Demo"> </a>

## 📦 Installation

1. Download this repository (green **Code** button → **Download ZIP**) and unzip it.
2. **Rename the folder to `horse-ranch`** (GitHub names it `horse-ranch-main`, and the resource must be called `horse-ranch`).
3. Put the `horse-ranch` folder inside your server's `resources` folder.
4. Add this line to your `server.cfg`:
   ```cfg
   ensure horse-ranch
   ```
5. Restart your server, walk up to the stable and press **E**.

## ⚙️ Configuration

Everything is in [`config.lua`](config.lua).

| Option | What it does | Default |
| --- | --- | --- |
| `Config.Stables` | Stable locations (`coords`, `heading`, `label`) | Valentine |
| `Config.InteractionDistance` | How close you must be to open the ledger | `1.5` |
| `Config.HorseBreeds` | Horse models, names and prices for sale | 4 breeds |
| `Config.BaseStatVariance` | +/- random roll on bought/bred stats | `15` |
| `Config.TrainingGainMin` / `Max` | Stat points gained per training | `2` / `6` |
| `Config.TrainingStaminaCost` | Condition cost per training session | `15` |
| `Config.TrainingCooldownMinutes` | Rest time between trainings per horse | `5` |
| `Config.BreedingFee` | Cost to breed two horses | `100` |
| `Config.SellPriceMultiplier` | Controls sell price from average stats | `4` |
| `Config.Framework` | `'standalone'`, `'vorp'` or `'rsg'` | `'standalone'` |

### Using it with VORP / RSG

The script runs standalone with a simple in-memory wallet (every player starts with `$1000`, reset on server restart). To use your framework's real money, edit the **money bridge** block at the top of [`server/main.lua`](server/main.lua) – the `GetMoney`, `AddMoney` and `RemoveMoney` functions – and connect them to your framework. Only the standalone wallet is implemented out of the box; the `vorp` and `rsg` values are hooks for you to fill in.

## 📁 Structure

```
horse-ranch/
├── fxmanifest.lua
├── config.lua
├── client/main.lua      -- prompts, NUI callbacks, training mini-game
├── server/main.lua      -- buying, breeding, training, selling, saving
├── html/                -- ledger UI (index.html, style.css, script.js)
├── docs/index.html      -- demo reel (GitHub Pages)
└── assets/              -- logo
```

## 💬 Support & contact

Questions, bugs or ideas? Reach the developer on Discord: **[Elite Development](https://discord.com/users/1162977745400254575)**

You can also open an [issue](../../issues) on this repository.

## 📄 License

Released under the [MIT License](LICENSE) – free to use and modify, with credit to **Elite Development** kept in place.

---

<p align="center"><sub>Made with ❤️ by <b>Elite Development</b></sub></p>
