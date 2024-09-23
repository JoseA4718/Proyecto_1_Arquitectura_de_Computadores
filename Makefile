# Nombre del archivo del histograma
HISTOGRAM_IMG = histograma.png

all: preprocess assembly histogram open_image

# Ejecuta preprocessing.py para generar input.txt
preprocess:
	python3 preprocessing.py

# Compila y ejecuta el archivo de ensamblador ARM
assembly_load:
	arm-linux-gnueabihf-as process_text.s -o process_text.o && arm-linux-gnueabihf-ld -static process_text.o -o process_text

# Ejecuta el script para generar el histograma
histogram:
	python3 histogram.py

# Abre la imagen generada
open_image:
	xdg-open $(HISTOGRAM_IMG)

clean:
	rm -f process_text.o process_text input.txt output.txt $(HISTOGRAM_IMG)
