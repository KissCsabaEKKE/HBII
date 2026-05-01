# HBII

Ez az R package a Humánbiológia II. – Alkalmazott biometria ZH adatait kéri le GitHubról.

## Telepítés

```r
install.packages("remotes")
remotes::install_github("KissCsabaEKKE/HBII")
```

## Használat

```r
library(HBII)

HB_DATA(
  neptun = "ABC123",
  ZH = 1,
  password = "BIOZH1"
)
```

A függvény létrehozza:

- `adat_teszt`
- `adat_korrelacio`
- `adat_generalas`
- `adat_szures`
