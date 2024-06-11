Qualcosa ho fatto; se possa essere adeguato non lo so.

Si appoggia su due utilit�, che devi installare separatamente:

xpdf-tools (in particolare, pdftotext):

https://dl.xpdfreader.com/xpdf-tools-win-4.05.zip

qpdf

https://github.com/qpdf/qpdf/releases/download/v11.9.0/qpdf-11.9.0-mingw64.exe

Il primo puoi scompattarlo e copiarlo dove vuoi; il secondo � da
eseguire, puoi installarlo dove ti propone, segui per il resto le
istruzioni. Alla domanda se aggiungere o no il programma alla path
puoi rispondere quello che vuoi; non ho fatto alcuna assunzione al
riguardo.

I due file che allego puoi copiarli dove pi� ti fa comodo. Apri con un
editor di testo (Notepad o altro) il file dividi_pdf_vta.exe.ini, e
controlla che i percorsi dei due programmi corrispondano a dove li hai
installati (per qpdf dovrebbe gi� andare bene, se hai lasciato le
opzioni default; per pdftotext sar� da aggiustare, secondo dove hai
copiato i file.)

All'esecuzione di dividi_pdf_vta.exe (creati magari un link sul
desktop per avviarlo) ti chieder� di indicargli il file pdf da
suddividere, poi fa le sue cose; i file pdf separati vengono
(dovrebbero venire) generati nella stessa cartella del pdf originale.

La convenzione per il nome del file che ho seguito �:
<numero albero>_<AAAA-MM-GG>_strumentale.pdf
(per altre tipologia si vedr� in seguito.)

Controlla che le suddivisioni siano corrette; il numero dell'albero
viene letto naturalmente dal pdf, e viene prodotto un nuovo pdf ogni
volta che cambia. Contando che la scritta "Nr. Albero ..." compaia una
sola volta per scheda, e che pdftotext sia sempre in grado di leggere
il testo, e che ci sia un testo da leggere. Credo di aver fatto anche
l'assunzione che il codice dell'albero sia sempre un numero, e che la
data sia sempre nella forma "GG/MM/AA". Queste cose sono sempre
abbastanza fragili, per forza di cose; essendo file generati da un
programma, comunque, ci sono buone probabilit� che la struttura sia
sempre quella e che vada tutto bene. Finch� non va male, almeno.

Nel nome del pdf ho messo dei trattini nella data, perch� la barra �
un bel carattere da mettere nel nome di un file (credo che proprio non
si possa); la scrittura con il trattino � poi anche una specie di
standard.

Il programma genera due file, nella stessa cartella del pdf originale:
un "<nome documento>.txt" che contiene (sperabilmente) tutto il testo
del pdf originale; e un "genera_pdf.bat" con i comandi di qpdf per
generare i vari pdf separati. Una volta fatto il lavoro, puoi
tranquillamente cancellarli.
