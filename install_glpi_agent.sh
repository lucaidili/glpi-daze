#!/bin/bash

# --- Configurazione ---
SERVER_URL="https://glpi.daze.eu"
AGENT_VERSION="1.15" # Aggiorna questo se esce una versione nuova dell'installer
# --------------------

# URL dell'installer ufficiale Perl
INSTALLER_URL="https://github.com/glpi-project/glpi-agent/releases/download/${AGENT_VERSION}/glpi-agent-${AGENT_VERSION}-linux-installer.pl"

# Controlla se lo script è eseguito come root
if [ "$EUID" -ne 0 ]; then
  echo "Per favore, esegui questo script come root o con sudo."
  exit 1
fi

echo "--- Installazione di GLPI Agent tramite l'installer ufficiale Perl ---"

# Passaggio 1: Installa le dipendenze minime (perl e wget)
echo "1. Verifico e installo le dipendenze (perl, wget)..."
if command -v apt-get &> /dev/null; then
    apt-get update > /dev/null 2>&1
    apt-get install -y perl wget > /dev/null
elif command -v dnf &> /dev/null; then
    dnf install -y perl wget > /dev/null
elif command -v yum &> /dev/null; then
    yum install -y perl wget > /dev/null
else
    echo "ERRORE: Impossibile determinare il gestore di pacchetti per installare 'perl' e 'wget'."
    exit 1
fi

# Passaggio 2: Scarica ed esegue l'installer ufficiale
echo "2. Scarico ed eseguo l'installer ufficiale..."
if wget -qO - "$INSTALLER_URL" | perl - --server="$SERVER_URL"; then
    echo "Installazione di base completata con successo."
    
    # Passaggio 3: Forza un inventario immediato
    echo "3. Forzo un inventario immediato per registrare subito il computer..."
    if command -v glpi-agent &> /dev/null; then
        glpi-agent --force
        echo "--- Processo completato! ---"
        echo "L'agente è stato installato e ha inviato il suo primo inventario a: $SERVER_URL"
    else
        # Questo non dovrebbe accadere se l'installazione è andata bene, ma è un controllo di sicurezza
        echo "ATTENZIONE: L'installazione sembra riuscita, ma il comando 'glpi-agent' non è stato trovato. Impossibile forzare l'inventario."
    fi
else
    echo "--- INSTALLAZIONE FALLITA ---"
    echo "L'installer ufficiale ha restituito un errore."
    exit 1
fi

exit 0
