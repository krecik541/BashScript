#!/bin/bash

#Author			: Maciej Szymczak ( s193456@student.pg.edu.pl )
#Created On		: 10.05.2023
#Last Modified By	: Maciej Szymczak ( s193456@student.pg.edu.pl )
#Last Modified On	: 16.05.2023
#Version		: 1.01
#
#Description		: Skrypt wykonujący kopie zapasową wskazanego przez użytkownika pliku lub folderu
#
#License		: GNU Version 3, 29 June 2007,
#			  2007 Free Software Foundation


#
# Na potrzeby testowania odkomentować czas został zmniejszony do 15 sekund w funkcji kopia
#


# Wartosci domyślne
FREQ=30
AMOUNT=5
LOCATION="kopia_zapasowa"

# Funkcja tworzące kopie zapasową pliku
fun_kopia_plik() {
    PLIK="$1"
    LOKALIZACJA="$2"
    CZESTOTLIWOSC="$3"
    LICZBA="$4"
    echo "Lokalizacja, w której znajdują się kopie zapasowe to $LOKALIZACJA"
    while [ 0 ]; do
    	if [ -f "$PLIK" ]; then
		echo "Aby zakończyć działanie programu wciśnij w konsoli CTRL+C"
		cp $PLIK "$LOKALIZACJA/backup_$(date +%Y%m%d%H%M%S)_$(basename $PLIK)" 
		cd $LOKALIZACJA
		LICZBA_DOTCHCZASOWYCH_KOPII=$(ls | wc -l)
		if (( $LICZBA_DOTCHCZASOWYCH_KOPII > $LICZBA )); then
			OLDEST=$(ls -t | tail -1)
			rm "$OLDEST"
		fi
		sleep $CZESTOTLIWOSC
		cd
	fi
    done
}

# Funkcja tworzące kopie zapasową plików które zostały w międzyczasie usunięte z foldera
fun_kopia_folder() {
    PLIK="$1"
    LOKALIZACJA="$2"
    CZESTOTLIWOSC="$3"
    echo "Lokalizacja, w której znajdują się kopie zapasowe to $LOKALIZACJA"
    cd
    cp -r $PLIK "/tmp"
    while [ 0 ]; do
    	if [ -d "$PLIK" ]; then
		echo "Aby zakończyć działanie programu wciśnij w konsoli CTRL+C"
		cd
		dir1_files=$(find "/tmp/$(basename $PLIK)" -type f -exec basename {} \;)
		for file in $dir1_files; do
			if [[ ! -e "$PLIK/$file" ]]; then
				cp "/tmp/$(basename $PLIK)/$file" "$LOKALIZACJA/backup_$(date +%Y%m%d%H%M%S)_$(basename $PLIK)" 
				echo "Wykonano kopie $file"
			fi
		done
		cd
		rm -R "/tmp/$(basename $PLIK)"
		cp -r $PLIK "/tmp"
		sleep $CZESTOTLIWOSC
	fi
    done
}

# Funkcja tworząca kopię zapasową
kopia() {
    PLIK="$1"
    LOKALIZACJA="$2"
    CZESTOTLIWOSC="$3"
    LICZBA="$4"
    
    if [ "$LOKALIZACJA" == "" ]; then
    	LOKALIZACJA=$LOCATION
    	if [ -d "$LOKALIZACJA" ]; then
    		LOKALIZACJA=$LOKALIZACJA$(($RANDOM))
    	fi
    	mkdir $LOKALIZACJA
    fi
    
    if [[ "$CZESTOTLIWOSC" == "" || "$CZESTOTLIWOSC" == "0" ]]; then
    	CZESTOTLIWOSC=$FREQ
    fi

    if [[ "$LICZBA" == "" || "$LICZBA" == "0" ]]; then
    	LICZBA=$AMOUNT
    fi
    
    # Na potrzeby testowania odkomentować czas został zmniejszony do 15 sekund w funkcji kopia
    CZESTOTLIWOSC=$((60*$CZESTOTLIWOSC))
    # CZESTOTLIWOSC=15
    
    if [ -f "$PLIK" ]; then
    	# Kopia zapasowa pliku
    	fun_kopia_plik "$PLIK" "$LOKALIZACJA" "$CZESTOTLIWOSC" "$LICZBA"
    fi
	    
    if [ -d "$PLIK" ]; then
    	# Kopia zapasowa folderu
    	fun_kopia_folder "$PLIK" "$LOKALIZACJA" "$CZESTOTLIWOSC"
    else 
    	exit 1
    fi
}

# Funkcja wyświetlająca informacje o skrypcie
fun_info() {
    zenity --info --title="Info" --text="Autor: Maciej Szymczak\nData: 15.05.2023\nLIcencja: GNU Version 3, 29 June 2007, 2007 Free Software Foundation"
}

# Funkcja wyświetlająca pomoc
fun_help() {
    zenity --info --title="Help" --text="Ten skrypt tworzy kopię zapasową wybranego pliku lub folderu.\n\n\
Opcje:\n\n\
- Wybierz plik lub folder: Wybierz plik lub folder, którego kopię zapasową chcesz stworzyć.\n\n\
- Wybierz lokalizację zapisu: Wybierz lokalizację, w której chcesz umieścić kopię zapasową.\n\n\
- Ustaw częstotliwość wykonywania kopii: Ustaw interwały pomiędzy kolejnymi zapisami.\n\n\
- Podaj liczbę przetrzymywanych kopii: Ustaw liczbę przetrzymywanych kopii zapasowych.\n\n\
- Help: Wypisz (tą) wiadomość pomocniczą.\n\n\
- Info: Wypisz informacje o skrypcie.\n\n\
- Rozpocznij: Kliknij tą opcję jeśli chcesz rozpocząć wykonywanie kopii zapasowych."
}

# Funkcja wyświetlająca menu
fun_menu() {
    zenity --list --title="Kopia zapasowa | Menu" --column="Opcje" --height 340 --width 360 --text="Wybierz opcje" \
    "Wybierz plik lub folder" "Wybierz lokalizację zapisu" "Ustaw częstotliwość wykonywania kopii" "Podaj liczbę przetrzymywanych kopii" "Rozpocznij" "Help" "Info" "Wyjście"
}

# Główna pętla menu
 while [ 0 ]; do
    WYBOR=$(fun_menu)

    case $WYBOR in
        "Wybierz plik lub folder")
            PLIK=$(zenity --file-selection --title="Wybierz plik lub folder")
            ;;
        "Wybierz lokalizację zapisu")
            LOKALIZACJA=$(zenity --file-selection --directory --title="Wybierz lokalizację zapisu")
            ;;
        "Ustaw częstotliwość wykonywania kopii")
            CZESTOTLIWOSC=$(zenity --scale --title "Ustaw częstotliwość wykonywania kopii" --text="Podaj częstotliwość wykonywania kopii (w minutach): ")
            ;;
        "Podaj liczbę przetrzymywanych kopii")
            LICZBA=$(zenity --scale --title="Podaj liczbę przetrzymywanych kopii" --text="Podaj liczbę przetrzymywanych kopii:")
            ;;
        "Rozpocznij")
        # Sprawdzenie, czy wszystkie wymagane opcje zostały ustawione
	    if [ -n $PLIK ]; then
	    	PLIK=$(echo "$PLIK" | cut -d'/' -f4-)
		kopia "$PLIK" "$LOKALIZACJA" "$CZESTOTLIWOSC" "$LICZBA"
		exit 0
	    else 
	    	zenity --error --title "Błędnie wprowadzone dane" --text "Nie wybrano pliku ani folderu"
	    fi
            ;;
        "Help")
            fun_help
            ;;
        "Info")
            fun_info
            ;;
        "Wyjście")
            exit 0
            ;;
        *)
            exit 1
            ;;
    esac

done