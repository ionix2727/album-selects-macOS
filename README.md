# Album Selects

Album Selects este o aplicație macOS dezvoltată în SwiftUI pentru selectarea rapidă și organizarea fotografiilor destinate albumelor foto.

Aplicația permite alegerea unui folder care conține fotografiile originale și încărcarea unei liste CSV sau TXT cu fotografiile dorite. Pe baza informațiilor din listă, aplicația caută imaginile corespunzătoare, creează automat folderul:

`Selecții pentru albumul foto`

și copiază fotografiile selectate în acest folder.

## Funcționalități

- Selectarea folderului cu fotografii.
- Încărcarea listelor CSV și TXT.
- Identificarea fotografiilor după numele fișierului.
- Potrivirea fotografiilor pe baza terminațiilor numerice, de exemplu `nume-1.jpg`.
- Crearea automată a folderului de selecție.
- Copierea fotografiilor selectate într-un folder separat.
- Detectarea fișierelor lipsă.
- Detectarea potrivirilor ambigue.
- Generarea unui raport de procesare.
- Jurnal detaliat al operațiunilor în timp real.
- Pagină de ajutor integrată.
- Secțiune About cu informații despre dezvoltator.

## Pentru cine este creată aplicația

Album Selects este destinat fotografilor, videografilor, studiourilor foto și profesioniștilor care trebuie să selecteze rapid fotografii pentru albume, fără să caute manual fiecare fișier.

## Tehnologii

- Swift
- SwiftUI
- macOS
- Foundation
- Combine
- AppKit

## Utilizare

1. Selectează folderul care conține fotografiile.
2. Selectează fișierul CSV sau TXT cu lista fotografiilor.
3. Apasă butonul „Creează selecția”.
4. Aplicația creează folderul `Selecții pentru albumul foto`.
5. Fotografiile găsite sunt copiate automat în folderul nou.
6. Verifică jurnalul și raportul generat pentru fișierele găsite, lipsă sau ambigue.

## Dezvoltator

**Rinculescu Ion**  
[www.fxstudio.ro](https://www.fxstudio.ro)  
Telefon: +40750400949
