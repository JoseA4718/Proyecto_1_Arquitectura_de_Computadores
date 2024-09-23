import matplotlib.pyplot as plt

def process_histogram(input_file):
    word_freq = {}

    # Leer el archivo de entrada
    with open(input_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    # Procesar cada línea
    for line in lines:
        # Dividir en palabra y frecuencia en formato ASCII
        parts = line.split()

        if len(parts) == 2:  # Asegurarse de que hay una palabra y una frecuencia
            word = parts[0]
            freq_ascii = parts[1]

            # Convertir frecuencia de ASCII a integer
            try:
                # Toma el primer carácter ASCII y lo convierte a su valor entero
                frequency = ord(freq_ascii)
            except ValueError:
                frequency = 0  # Manejo de errores si la conversión falla

            word_freq[word] = frequency

    # Crear un histograma usando matplotlib
    words = list(word_freq.keys())
    frequencies = list(word_freq.values())

    plt.figure(figsize=(10, 6))
    plt.bar(words, frequencies, color='skyblue')
    plt.xlabel('Palabras')
    plt.ylabel('Frecuencia')
    plt.title('Histograma de Frecuencia de Palabras')
    plt.xticks(rotation=45)
    plt.tight_layout()

    # Guardar el histograma como imagen
    plt.savefig('histograma.png')
    plt.show()

# Usar la función
input_file = 'output.txt'  # Cambia esto por el nombre de tu archivo de entrada

process_histogram(input_file)
