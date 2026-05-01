HB_DATA <- function(neptun, ZH = 1, password, config_url = NULL) {

  if (missing(neptun) || missing(password)) {
    stop("Adja meg a neptun és password argumentumokat.")
  }

  if (is.null(config_url)) {
    config_url <- "https://raw.githubusercontent.com/KissCsabaEKKE/HB_ZH/main/zh_config.csv"
  }

  config <- tryCatch(
    read.csv(config_url, stringsAsFactors = FALSE, fileEncoding = "UTF-8"),
    error = function(e) stop("Nem sikerült elérni a ZH konfigurációs fájlt.")
  )

  sor <- config[config$ZH == ZH, ]

  if (nrow(sor) != 1) {
    stop("Nincs ilyen ZH azonosító a konfigurációs fájlban.")
  }

  if (!isTRUE(as.logical(sor$aktiv))) {
    stop("Ez a ZH jelenleg nem aktív.")
  }

  most <- Sys.time()
  kezdet <- as.POSIXct(sor$kezdet, tz = "Europe/Budapest")
  vege <- as.POSIXct(sor$vege, tz = "Europe/Budapest")

  if (is.na(kezdet) || is.na(vege)) {
    stop("A kezdési vagy zárási időpont hibásan szerepel a konfigurációban.")
  }

  if (most < kezdet || most > vege) {
    stop("A ZH jelenleg nem elérhető.")
  }

  if (password != sor$jelszo) {
    stop("Hibás jelszó.")
  }

  seed <- sum(utf8ToInt(toupper(neptun))) + as.integer(ZH) * 10000
  set.seed(seed)

  kod <- tryCatch(
    readLines(sor$script_url, warn = FALSE, encoding = "UTF-8"),
    error = function(e) stop("Nem sikerült letölteni a ZH scriptet.")
  )

zh_env <- new.env(parent = globalenv())

zh_env$neptun <- neptun
zh_env$ZH <- ZH
zh_env$seed <- seed

eval(parse(text = kod), envir = zh_env, enclos = parent.frame())

  objektumok <- ls(zh_env)
  atadando <- objektumok[grepl("^adat_", objektumok)]

  for (obj in atadando) {
  assign(obj, get(obj, envir = zh_env), envir = .GlobalEnv)
}

if ("feladat_szoveg" %in% objektumok) {
  
  # Feladatszöveg mentése az Environment-be
  assign("feladat_szoveg", zh_env$feladat_szoveg, envir = .GlobalEnv)
  
  # Feladatszöveg kiírása a Console-ba
  cat("\n")
  cat(zh_env$feladat_szoveg)
  cat("\n")
}

message("\nA ZH adatai elkészültek.")
message("Létrehozott objektumok: ", paste(c(atadando, "feladat_szoveg"), collapse = ", "))
message("Egyedi seed: ", seed)

invisible(c(atadando, "feladat_szoveg"))
}
