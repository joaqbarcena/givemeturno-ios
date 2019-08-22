# 🍅 🥑 GiveMeTurno 🍔 🍗
## Update : 22/08 - 3:44 (jaja)
Esto ultimamente se me volvio como una droga, que me hace negrear codigo como un campeon con tal que pueda reservar el turno, el 21 tiraron el server a las 8:05-15
pero no piensan dar a torcer el brazo, le transmitieron las quejas de que el captcha era bastante ilegible y lo agrandaron, el 21 profundice en las sesiones del server
y encontres que el campo `TOBA_SESSID` es el que rige la session del usuario i.e.
si haces el captcha y guardas el `TOBA_SESSID` como cookie siempre, nunca (en teoria) deberias rehacer el captcha ya que esa session ya se "logueo" y aca esta el
negrero resultado de eso

## Update : 20/08 
Cerca del mediodia en login pusieron un captcha(lo cual esta bien), la idea es en el paso intermedio del login traer el captcha para resolverlo y que conitnue igual
Tambien cambiaron partes de la pagina asi que hubieron modificaciones en el regex del parser

## Aun no ha sido completamente probado, hoy viernes (16/8) se hacen las pruebas finales ya que dependen del server de la UNC

Hace poco (la verdad no se cuando), cambiaron una vez mas el sistema de turnos del comedor de la UNC (Universidad Nacional de Cordoba) donde ahora hay que :  

- Sacar `reservacion` via web, (bien temprano)
- Imprimir la `reservacion` ahi mismo
- Ir a la cola con el turno ya impreso

No es una mala idea, agiliza bastante, pero es cierto que los
turnos desaparecen temprano en la mañana.  
Este script (por ahora) hace en un solo comando esa reservacion de turno.

### Requisitos
La verdad es que no conosco nada sobre Xcode/iOS por lo que puede que hayan temas
a configurar, `No` usa ningun manejador de dependencia (ya que en si es una pavada)
asi que en si bastaria con `Xcode`

### Uso
A diferencia del script, no encontre algo como un `WorkManager` o `AlarmManager`
analogo de `Android` aca en `iOS` lei que para dichas tareas usabana `Timers` o
disparaban notificaciones locales, asi que solo tiene un `TextField` para poner
el `Nro de credencial` el cual se guarda en las `UserPreferences` y un boton que
dispara el evento, en `label` notifica cual fue el resultado de la operacion


