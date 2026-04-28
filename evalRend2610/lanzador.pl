#!/usr/bin/perl
#**************************************************************
#         		Pontificia Universidad Javeriana
#     Autor: J. Corredor 
#	  Nombre Estudiante: David Pedraza, Oscar Pinilla, Johan Barreto
#     Fecha: 27/04/2026
#     Materia: Sistemas Operativos
#     Tema: Taller de Evaluación de Rendimiento
#     Fichero: script automatización ejecución por lotes 
#****************************************************************/

$Path = `pwd`;
chomp($Path);

@Nombre_Ejecutable = ("mxmPosixFxC","mxmPosixFxT","mxmForkFxC","mxmForkFxT");
@Size_Matriz  = ("200", "800", "1600", "3200");
@Num_Hilos    = (1,2,4);
$Repeticiones = 30;
$Resultados	  = "Soluciones";
$Binarios	  = "bin";


# Bucle principal que recorre cada tipo de ejecutable disponible
foreach $nombre (@Nombre_Ejecutable){
#Itera sobre los tamaños de matriz definidos
	foreach $size (@Size_Matriz){
		foreach $hilo (@Num_Hilos) {
			$file = "$Path/$Resultados/$nombre-".$size."-Hilos-".$hilo.".dat";
			printf("$file \n");
# Ciclo de repeticiones para recolectar datos estadísticos de rendimiento
			for ($i=0; $i<$Repeticiones; $i++) {
				system("$Path/$Binarios/$nombre $size $hilo  >> $file");
				printf("$Path/$Binarios/$nombre $size $hilo \n");
			}
			close($file);
		}
	}
}	
