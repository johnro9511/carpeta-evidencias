/*  TITULO: BALANZA DIGITAL CON TRANSMISOR HX711 & DOS CELDAS DE CARGA; 
            PARA EL CALCULO DE RACIMOS DE BANANOS PROCESADOS SOBRE CABLE VIA.

    AUTOR: DEPTO. DE TECNOLOGÍAS Y COMUNICACIONES - KAVIDAC PRODUCE SA DE CV
    DESARROLLADOR: LSC. DANNY LOPEZ YAU & LSC. JUAN RO. MALDONADO

    :: DESCRIPCIÓN DEL PROGRAMA ::

    El programa tiene la finalidad de visualizar el peso de cada uno de los racimos que pasen sobre las celdas de carga,
    por tal razón se contempla dos celdas de carga para realizar un promedio más certero entre ambas celdas esto realizado
    por medio de un aplicativo de java conectado por usb al arduino.

    ESQUEMA DE CONEXION:
                                      +-----+
         +----[PWR]-------------------| USB |--+
         |                            +-----+  |
         |         GND/RST2  [ ][ ]            |
         |       MOSI2/SCK2  [ ][ ]  A5/SCL[ ] |
         |          5V/MISO2 [ ][ ]  A4/SDA[ ] |
         |                             AREF[ ] |
         |                              GND[ ] |
         | [ ]N/C                    SCK/13[ ] |
         | [ ]IOREF                 MISO/12[ ] |
         | [ ]RST                   MOSI/11[ ]~|
         | [ ]3V3    +---+               10[ ]~|
         | [ ]5v    -| A |-               9[ ]~|
         | [ ]GND   -| R |-               8[ ] |
         | [ ]GND   -| D |-                    |
         | [ ]Vin   -| U |-               7[ ] |
         |          -| I |-               6[ ]~|
   SCK1  | [ ]A0    -| N |-               5[ ]~|
    DT1  | [ ]A1    -| O |-               4[ ] |
   SCK2  | [ ]A2     +---+           INT1/3[ ]~|
    DT2  | [ ]A3                     INT0/2[ ] |
         | [ ]A4/SDA  RST SCK MISO     TX>1[ ] |
         | [ ]A5/SCL  [ ] [ ] [ ]      RX<0[ ] |
         |            [ ] [ ] [ ]              |
         |  UNO_R3    GND MOSI 5V  ____________/
          \_______________________/

  NOTAS **:

   - Conexiones del transmisor de celda de carga HX711:
     - ALIMENTACIÓN:
       - Pin VCC del HX711 --> +5V de Arduino.
       - Pin GND del HX711 --> GND de Arduino.
     - ENTRADAS:
       - Pin E+ del HX711 --> Cable Rojo de la celda de carga.
       - Pin E- del HX711 --> Cable Negro de la celda de carga.
       - Pin A- del HX711 --> Cable Blanco de la celda de carga.
       - Pin A+ del HX711 --> Cable Verde de la celda de carga.
     - SALIDAS:
      Transmisor 1
       - Pin SCK del HX711 --> Pin analógico A0 de Arduino.
       - Pin DT del HX711  --> Pin Analógico A1 de Arduino.
      Transmisor 2
       - Pin SCK del HX711 --> Pin analógico A2 de Arduino.
       - Pin DT del HX711  --> Pin Analógico A3 de Arduino.
*/

// Librería para utilizar el transmisor de celda de carga HX711
#include "HX711.h"

#define DT1   A1  // Pin analógico A1 para el pin DT del transmisor de celda de carga HX711
#define SCK1  A0  // Pin analógico A0 para el pin SCK del transmisor de celda de carga HX711
#define DT2   A3  // Pin analógico A1 para el pin DT del transmisor de celda de carga HX711
#define SCK2  A2  // Pin analógico A0 para el pin SCK del transmisor de celda de carga HX711

float valor_pesado1 = 0; //Variable que almacenara el peso de la celda 1
float valor_pesado2 = 0; //Variable que almacenara el peso de la celda 2
float val_real = 0; // valor de sumatoria
int cont = 0; // contador de pasadas

// Creación del objeto para el transmisor de celda de carga HX711
HX711 balanza1(DT1, SCK1);// constructor 1
HX711 balanza2(DT2, SCK2);// constructor 2
  
/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */

void setup(){
  Serial.begin(57600);// Comienzo de la comunicación y velocidad en baudios con el monitor serie
  
  //balanza1.set_gain(128);
  balanza1.set_scale(-32698);//-32865//(31782.33)-32698//-32698 Establecemos ESCALA calculada ant.
  balanza1.tare(10);

  //balanza2.set_gain(32);
  balanza2.set_scale(-37550);//-8221//(31782.333)-31900//-37550 Establecemos ESCALA calculada ant.
  balanza2.tare(10); // -33055
}// setup

void loop(){
  valor_pesado1 = balanza1.get_units(1); // obt. valor de pesaje 1
  valor_pesado2 = balanza2.get_units(1); // obt. valor de pesaje 2

  /* Serial.print("b1 :");
  Serial.println(valor_pesado1);
  
  Serial.print("b2 :");
  Serial.println(valor_pesado2); */

  if(valor_pesado2 < 8){// valida valor de la bascula2
    //--> valor_pesado2 = 0; 
    cont = 0;
  }else{// valor balanza 2 
    cont ++;
  }
  // AQUI VAN LAS CONDICIONES DE CALCULO DE PESO EN KG  
  
  if(cont == 2){// num. de pasada valida
    val_real = valor_pesado1 + valor_pesado2; // sumatoria de valores 1 y 2
    Serial.println(val_real);// manda el dato 1 x serial
    cont ++; // aumenta el contador p/salir del bucle 
    //--> delay(20); // pausa si es necesaria
  }// evalua pasada 2
}// loop 116
