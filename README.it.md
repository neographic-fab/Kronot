# Kronot

[English version](README.md)

**Kronot** è un controllo SwiftUI nativo per selezionare un **intervallo temporale su un quadrante radiale di 24 ore**.

È pensato per interfacce in cui una porzione visiva della giornata è più chiara di un picker tradizionale, per esempio:

- routine del sonno
- finestre di disponibilità
- sessioni di focus
- abitudini quotidiane
- qualsiasi esperienza in cui l’utente deve *vedere* la parte di giornata selezionata

Kronot mantiene l’API pubblica di integrazione abbastanza piccola, ma espone due livelli di personalizzazione ben distinti:

- `Parameters` per comportamento e contenuto
- `DesignTokens` per lo stile visivo

## Anteprima

### Default
![Kronot default](Images/default_Kronot.png)

### Dark Mode
![Kronot customized](Images/darkMode_Kronot.png)

### Azioni
![Kronot localized](Images/move_start_Kronot.png)

### Localizzato
![Kronot accessibility](Images/arabic_Kronot_Translate.png)


## Requisiti

Attualmente Kronot richiede:

- **iOS 18.0+**
- **Swift 6 mode**
- **Swift tools version 6.3**
- **SwiftUI**

Da `Package.swift`:

```swift
// swift-tools-version: 6.3
platforms: [.iOS(.v18)]
swiftLanguageModes: [.v6]
```

## Installazione

### Xcode

1. Apri il progetto.
2. Vai su **File > Add Package Dependencies...**
3. Incolla l’URL del repository.
4. Aggiungi la libreria `Kronot` al target desiderato.

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/your-name/Kronot.git", branch: "main")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "Kronot", package: "Kronot")
        ]
    )
]
```

Poi importa il modulo dove ti serve:

```swift
import Kronot
```

## Caratteristiche principali

- selezione radiale di un intervallo su 24 ore
- thumb iniziale e finale trascinabili
- track attivo trascinabile per spostare tutto l’intervallo mantenendo la durata
- comportamento di snap configurabile
- durata minima e massima configurabili
- personalizzazione via environment con `Parameters` e `DesignTokens`
- stringhe integrate localizzate
- formattazione oraria adattata alla locale
- supporto VoiceOver con adjustable actions
- densità delle etichette radiali adattata a Dynamic Type
- supporto a Differentiate Without Color
- feedback aptico durante l’interazione

## Quick Start

Kronot lavora con un `Binding<TimeRange>`.

```swift
import SwiftUI
import Kronot

struct ContentView: View {
    @State private var range: TimeRange = .currentTime(snapHours: 5)

    var body: some View {
        VStack(spacing: 24) {
            Kronot(range: $range)
                .frame(width: 320, height: 320)

            Text("Start: \(range.start.hour):\(String(format: "%02d", range.start.minute))")
            Text("End: \(range.end.hour):\(String(format: "%02d", range.end.minute))")
        }
        .padding()
    }
}
```

## Modello principale

Kronot usa `TimeRange` come tipo pubblico principale.

```swift
public struct TimeRange: Equatable {
    public var start: Components
    public var end: Components
}
```

`TimeRange.Components` contiene:

```swift
public struct Components: Equatable {
    public var hour: Int
    public var minute: Int
}
```

### Creare un range personalizzato

```swift
let range = TimeRange(
    start: .init(hour: 22, minute: 0),
    end: .init(hour: 6, minute: 30)
)
```

I range che attraversano la mezzanotte sono supportati normalmente.

### Creare un range a partire dall’ora corrente

```swift
let range = TimeRange.currentTime(snapHours: 5)
```

Questo crea un intervallo che parte dall’ora corrente e termina `snapHours` dopo.

## Modello di interazione

Kronot supporta tre modalità principali:

1. trascinamento del thumb di **start**
2. trascinamento del thumb di **end**
3. trascinamento del **track attivo** per spostare tutto l’intervallo

Durante l’interazione, Kronot:

- applica lo snap al passo configurato
- gestisce correttamente il wrap-around oltre la mezzanotte
- rispetta durata minima e massima attive
- emette haptics di selezione

## Panoramica della configurazione

Kronot separa la configurazione in due livelli:

- `Parameters` per **comportamento e contenuto**
- `DesignTokens` per **stile visivo**

Entrambi vengono applicati tramite view modifier e passati via environment.

---

## Parameters

Usa `.parameters { ... }` per configurare comportamento e contenuto.

```swift
Kronot(range: $range)
    .parameters { parameters in
        parameters.behavior.snapMode = .everyQuarterHour
        parameters.behavior.minActiveHours = 2
        parameters.behavior.maxActiveHours = 12
    }
```

### Behavior

`Parameters.Behavior` controlla:

- `minActiveHours`
- `maxActiveHours`
- `snapMode`

Snap mode disponibili:

```swift
.everyFiveMinutes
.everyTenMinutes
.everyQuarterHour
.everyHalfHour
.everyHour
```

I valori di behavior vengono sanitizzati automaticamente quando sono inseriti nell’environment.

Regole di normalizzazione attuali:

- `minActiveHours` viene clampato in `1...23`
- `maxActiveHours` viene clampato in `1...23`
- `minActiveHours` non può superare `maxActiveHours`

### Content

`Parameters.Content` controlla:

- etichette radiali
- accessori dei readout

#### Etichette radiali

```swift
Kronot(range: $range)
    .parameters { parameters in
        parameters.content.radialLabels.showMeridiem = true
        parameters.content.radialLabels.frequency = .everyTwoHours
    }
```

Frequenze disponibili:

```swift
.everyHour
.everyTwoHours
.cardinal
```

#### Accessori dei readout

Kronot può mostrare un accessorio per il readout di start e per quello di end.

Tipi disponibili:

```swift
.none
.text(LocalizedStringResource)
.verbatim(String)
.icon(systemName: String)
```

Esempio:

```swift
Kronot(range: $range)
    .parameters { parameters in
        parameters.content.readout.start = .icon(systemName: "moon.fill")
        parameters.content.readout.end = .icon(systemName: "sun.max.fill")
    }
```

---

## DesignTokens

Usa `.designTokens { ... }` per personalizzare l’aspetto visivo.

```swift
Kronot(range: $range)
    .designTokens { tokens in
        tokens.track.lineWidth = 24
        tokens.tick.inset = 6
    }
```

I design tokens sono divisi in:

- `track`
- `tick`
- `radialLabels`
- `thumb`
- `readouts`

### Track

`DesignTokens.TrackTokens` controlla line width, inset, line cap, visibilità del marker e stile di disegno del track base e del range attivo.

Esempio:

```swift
Kronot(range: $range)
    .designTokens { tokens in
        tokens.track.lineWidth = 24
        tokens.track.inset = 12
        tokens.track.showMarker = true
        tokens.track.markerLengthFactor = 0.35
        tokens.track.setStyle(.solid(.secondary.opacity(0.15)), for: .base)
        tokens.track.setStyle(.angular(.green, .yellow, .orange), for: .range)
    }
```

I valori del track vengono sanitizzati automaticamente. Per esempio:

- `lineWidth` viene riportata in un intervallo sicuro
- `inset` non può essere negativo
- i valori del marker vengono normalizzati entro limiti validi

### Tick

`DesignTokens.TickTokens` controlla l’aspetto dei tick major e minor.

```swift
Kronot(range: $range)
    .designTokens { tokens in
        tokens.tick.major.length = 14
        tokens.tick.major.width = 2
        tokens.tick.minor.length = 8
        tokens.tick.minor.width = 1
        tokens.tick.inset = 4
    }
```

### Radial Labels

`DesignTokens.RadialLabelsTokens` controlla inset, colore e font delle etichette radiali.

```swift
Kronot(range: $range)
    .designTokens { tokens in
        tokens.radialLabels.inset = 18
        tokens.radialLabels.color = .secondary
        tokens.radialLabels.font = .footnote
    }
```

### Thumb

`DesignTokens.ThumbTokens` permette di stilizzare in modo indipendente i thumb di start e di end.

Ogni thumb può configurare, tra le altre cose:

- colore di riempimento
- visibilità dell’icona
- nome dell’icona
- colore dell’icona
- scala
- ombra

```swift
Kronot(range: $range)
    .designTokens { tokens in
        tokens.thumb.start.color = .white
        tokens.thumb.start.iconSystemName = "moon.fill"
        tokens.thumb.end.color = .white
        tokens.thumb.end.iconSystemName = "sun.max.fill"
        tokens.thumb.end.scale = .medium
    }
```

### Readouts

`DesignTokens.ReadoutsTokens` controlla tipografia e colore per readout di start, end, durata e accessori, includendo dove previsto stati idle e focused.

```swift
Kronot(range: $range)
    .designTokens { tokens in
        tokens.readouts.start.idle.font = .title3
        tokens.readouts.start.focused.font = .title
        tokens.readouts.end.focused.color = .primary
        tokens.readouts.duration.color = .secondary
        tokens.readouts.accessory.focused.fontWeight = .semibold
    }
```

## Esempio completo

```swift
import SwiftUI
import Kronot

struct DemoView: View {
    @State private var range = TimeRange(
        start: .init(hour: 22, minute: 0),
        end: .init(hour: 6, minute: 0)
    )

    var body: some View {
        Kronot(range: $range)
            .frame(width: 320, height: 320)
            .parameters { parameters in
                parameters.behavior.snapMode = .everyQuarterHour
                parameters.behavior.minActiveHours = 2
                parameters.behavior.maxActiveHours = 12
                parameters.content.radialLabels.showMeridiem = true
                parameters.content.radialLabels.frequency = .everyTwoHours
                parameters.content.readout.start = .icon(systemName: "moon.stars.fill")
                parameters.content.readout.end = .icon(systemName: "sun.max.fill")
            }
            .designTokens { tokens in
                tokens.track.lineWidth = 24
                tokens.track.inset = 10
                tokens.track.setStyle(.solid(.secondary.opacity(0.15)), for: .base)
                tokens.track.setStyle(.angular(.indigo, .purple, .pink), for: .range)
                tokens.track.markerColor = .white.opacity(0.7)
                tokens.tick.major.color = .primary
                tokens.tick.minor.color = .secondary
                tokens.thumb.start.iconSystemName = "moon.fill"
                tokens.thumb.end.iconSystemName = "sun.max.fill"
                tokens.radialLabels.font = .footnote
            }
            .padding()
    }
}
```

## Localizzazione

Kronot è configurato con:

```swift
defaultLocalization: "en"
```

Il package include uno string catalog con risorse localizzate integrate per etichette e testi di accessibilità.

Localizzazioni attualmente incluse:

- Arabo (`ar`)
- Tedesco (`de`)
- Inglese (`en`)
- Spagnolo (`es`)
- Francese (`fr`)
- Ebraico (`he`)
- Hindi (`hi`)
- Indonesiano (`id`)
- Italiano (`it`)
- Giapponese (`ja`)
- Coreano (`ko`)
- Olandese (`nl`)
- Polacco (`pl`)
- Portoghese brasiliano (`pt-BR`)
- Rumeno (`ro`)
- Russo (`ru`)
- Thailandese (`th`)
- Turco (`tr`)
- Ucraino (`uk`)
- Vietnamita (`vi`)
- Cinese semplificato (`zh-Hans`)
- Cinese tradizionale (`zh-Hant`)

Kronot adatta anche la formattazione dell’orario in base alla locale corrente.

## Accessibilità

Kronot include supporto per:

- adjustable actions VoiceOver per i valori di start e end
- etichette di accessibilità localizzate
- densità delle etichette radiali adattata a Dynamic Type
- supporto a Differentiate Without Color per la visibilità del marker

## Test

Kronot include una suite di test focalizzata sulla logica core e sul comportamento del formatter.

La copertura attuale include:

- calcolo della durata del range
- comportamento wrap-around oltre la mezzanotte
- normalizzazione dei minuti e delta con wrap
- comportamento di snap
- vincoli di durata minima e massima attiva
- logica pura di interazione del range
- comportamento localizzato del formatter per radial labels, time text e duration text

Per eseguire i test:

```bash
swift test
```

## Note

- Kronot è attualmente focalizzato su **iOS** e **SwiftUI**.
- Il componente è costruito attorno a un modello circolare di giornata su 24 ore.
- Stile e comportamento sono separati intenzionalmente, così l’integrazione resta piccola ma la personalizzazione rimane flessibile.

## Ringraziamenti

Kronot è cresciuto anche grazie al supporto di persone che hanno aiutato con generosità durante lo sviluppo:

- **Artem Mirzabekian**  
  LinkedIn: https://www.linkedin.com/in/artem-mirzabekian/  
  GitHub: https://github.com/Livsy90
  Artem ha dato un supporto prezioso ed è stato particolarmente importante durante l’implementazione di VoiceOver.

- **Andrei Ilnitskii**  
  LinkedIn: https://www.linkedin.com/in/andreiilnitskii/  
  GitHub: https://github.com/indieupme 
  Andrei ha avuto un ruolo chiave nel lavoro di localizzazione, con un supporto particolarmente importante per la localizzazione in russo.

## Revisione delle localizzazioni

Ulteriore revisione delle localizzazioni è stata fornita da parlanti madrelingua per:

- Cinese semplificato
- Cinese tradizionale
- Rumeno
- Arabo

Queste revisioni sono state fornite privatamente da parlanti madrelingua che non sono elencati pubblicamente qui.

## Licenza

Kronot è distribuito sotto **licenza MIT**.
Per i dettagli, vedi il file [LICENSE](LICENSE).
