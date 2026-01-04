# ZCANTAG Web App

Flutter Web application for ZCANTAG.

## Status

Noch nicht implementiert. Wird Code mit mobilapp teilen.

## Features laut KONZEPTSCHREIBEN.md

### 1.2 Web-App (User-Bereich)

| Feature | Free | Basic+ |
|---------|------|--------|
| Registrierung & Login | Ja | Ja |
| Visitenkarten erstellen & bearbeiten | Ja | Ja |
| Visitenkarten teilen (Link, QR, E-Mail) | Ja | Ja |
| **Kontakte anzeigen** | **NEIN** (App-Download Aufforderung) | Ja |
| Responsive Oberflaeche | Ja | Ja |

### 1.3 Admin-Panel (NUR WEB - nicht in Mobile App!)

Das Admin-Panel ist **exklusiv fuer die Web-App** und bietet:

| Feature | Basic | Premium | Enterprise |
|---------|-------|---------|------------|
| Unternehmensverwaltung | Ja | Ja | Ja |
| Mitarbeiter-Accounts (RBAC) | Vereinfacht | Vereinfacht | Voll anpassbar |
| Push-Kampagnen erstellen | - | 2/Woche | Unbegrenzt |
| Push-Segmentierung | - | Ja | Ja + A/B-Tests |
| **Analytics** | Nur Karten-Anzahl | Open Rate, CTR | + Conversion, Echtzeit |
| **Reporting & Export** | - | CSV | CSV/PDF/XLSX |
| Echtzeit-Dashboard | - | - | Ja |

### Rollen-/Teamverwaltung (Admin-Panel)

```
Super-Admin (Geschaeftsfuehrung)
    └── Regionalleiter (mehrere Standorte)
        └── Filialleiter (ein Standort)
            └── Teamleiter (eine Abteilung)
                └── Mitarbeiter (einzelne Person)
```

**Nur im Web Admin-Panel:**
- Benutzerrollen zuweisen (nur Super-Admin)
- Subkarten erstellen/verwalten
- Team-Statistiken einsehen
- Push-Kampagnen an Zielgruppen senden

## Mobile App vs Web App

| Feature | Mobile App | Web App |
|---------|-----------|---------|
| Kontakte anzeigen (Free) | Ja | Nein |
| QR-Code Scanner | Ja (nativ) | Eingeschraenkt |
| Push-Benachrichtigungen empfangen | Ja | Nein |
| **Admin-Panel** | **Nein** | **Ja** |
| **Team-/Mitarbeiterverwaltung** | **Nein** | **Ja** |
| **Analytics Dashboard** | **Nein** | **Ja** |
| **Push-Kampagnen erstellen** | **Nein** | **Ja** |

## Technologie

- **Framework**: Flutter Web (Code-Sharing mit mobilapp)
- **Hosting**: Vercel (Static Site)
- **SEO**: Nicht kritisch (Karten werden via Direktlinks geteilt)

## Implementierungs-Hinweise

1. **Shared Code mit mobilapp/**
   - Models, Services, API-Client
   - Auth-Flow
   - Basis-Widgets

2. **Web-spezifische Features**
   - Admin-Panel (komplett neu)
   - Analytics Dashboard
   - Team-Verwaltung UI
   - Push-Kampagnen Editor
   - Export-Funktionen

3. **Free-User Einschraenkungen**
   - Kontakt-Liste zeigt App-Download Aufforderung
   - Links zu App Store / Play Store

4. **Responsive Design**
   - Desktop-optimiert fuer Admin-Panel
   - Mobile-Browser Support fuer User-Bereich
