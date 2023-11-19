# pacman

// Wyświetlanie mapy nie na przerwaniach, po pamięci ekranu

## TODO
- [x] Zainicjowanie mapy w .data
- [ ] Wczytywanie mapy do pamięci w sposób zorganizowany.
- [x]	Input – keyboard
- [ ]	Poruszanie gracza. Będziemy musieli usuwać kulki do zbierania, a jeżeli korytarz to będzie  “.”, trzeba będzie zamieniać kropke ze znakiem gracza.
- [ ] Kolizja
- [ ]	Timer – co ‘x’ ms jest wyświetlana mapa, ruch ducha i gracza.
- [ ]	“AI” duchów - tam gdzie wolna droga, to idź.
- [ ] Score
- [ ] Game over
- [ ]	Restart dopóki lives > 1
- [ ] Zabijanie duchów poprzez podniesienie jakiegoś gówna.
- [ ] Win condition

Not done
Done

## Mapa:


- Obiekty:
- Pacman = “C”
- Duchy = “G”
- Wisnie = “o”
- Korytarz = “ ” (może być też “.”)
- Ściana = “X”
- Kulki do zbierania = “*”


## Zasada działania/logika:
- Do pamięci zostaje wczytana mapa (z pliku/hardcodowana).
- Program parsuje najpierw mapę i ustawia pozycję (X i Y) potworów, ścian i gracza?
- W jaki sposób sprawdzać, że np. Gracz idzie w lewo i na pozycji gracz + lewo jest ściana?

### Moim zdaniem powyższa implementacja (X,Y) nie będzie najprostsza do zaimplementowania.
Mój pomysł (1): 
Wczytujemy mape do pamięci. Mamy adres początkowy, wiemy, że każdy character to jest jeden bajt, więc mamy offset każdego następnego znaku. Ustalimy offset wiersza, czyli jak jest “\n” w pliku, to wiemy, że + offset będzie kolejny wiersz.
Wtedy wydaje mi się, że mając stack pointer, bądź inne narzędzie do śledzenia adresu, wystarczy, że będziemy sprawdzać jaki znak jest przy tym adresie + offset, zwiększając/zmniejszając pointer lokacji, by odzwierciedlać “ruch” gracza. To samo z duchami które się przemieszczają.
Możemy też wpisać mapę do pamięci bezpośrednio w pliku źródłowym w .data Każdy znak jest ustawiany po sobie, więc aby odróżnić następny wiersz od drugiego, po zakonczeniu wierszu dalibysmy padding jakiegos znaku specjalnego, np. Zer czy coś. Wczytalibyśmy także zmienne pomocnicze takie jak MAP_W i MAP_H, które konsekwentnie oznaczają ilość bajtów (znaków) kolumn oraz ile tych wierszów by było.

## Zespół
- Miłosz Rzyczniak
- Szymon Franz
- Adam Trzpis
