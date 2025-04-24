# Projet PFA

On a décidé d’implémenter un jeu de plateforme par défaut, en utilisant le asset pack suivant : [https://ansimuz.itch.io/sunny-land-pixel-game-art](https://ansimuz.itch.io/sunny-land-pixel-game-art).  
On a choisi de faire simple, en s’inspirant des vieux jeux de plateforme, où les ennemis ont des schémas de mouvement répétitifs et où les mécaniques liées aux plateformes restent assez basiques.

## Ce qu'on a implémenté

### Système d’animations
On a mis en place un système qui permet d’animer des entités assez facilement.  
Avec un *spritesheet*, on indique la position souhaitée dans la feuille, les dimensions de l’entité, et les frames. Le système se charge ensuite d’animer les frames en fonction du temps.

### Ennemis
On a implémenté 5 ennemis différents :

- 2 qui volent (Fantôme et Aigle)
- 2 terrestres (Slime et Rat)
- 1 Boss

Les 5 ont des mouvements différents selon un patron répétitif basé sur le temps.  
Ils ont également des animations différentes. Le joueur peut les tuer en leur sautant dessus (à la Mario Bros). Inversement, ils peuvent infliger des dégâts au joueur lors des collisions horizontales.

D’ailleurs, les dégâts font rebondir le joueur dans le sens opposé, de façon proportionnelle à sa vitesse, et lui donnent une immunité temporaire de 0,5 seconde.

## Objets / Blocs Spéciaux

- **Cerises** :  
  Le joueur peut ramasser des cerises pour récupérer un demi-cœur.

- **Piques** :  
  Les piques sont des blocs qui infligent des dégâts au joueur, peu importe le sens de la collision.

### Plateformes

- **Plateformes normales** :  
  Le joueur peut passer par-dessous.

- **Plateformes qui tombent** :  
  Elles peuvent aussi être traversées par-dessous, mais tombent lorsqu'on les touche par le haut.

- **Grandes et petites boîtes** :  
  Ce sont techniquement des plateformes que l’on peut déplacer, mais attention : elles se cassent si elles touchent des piques.

### Système de Checkpoints / Respawn
Si le joueur meurt, il est instantanément renvoyé au dernier checkpoint franchi.  
Toutes les entités détruites ou consommées dans la map réapparaîtront.

### Petite UI
En haut à gauche, on peut voir la vie du joueur représentée par des cœurs.

### Map
Notre map est représentée par un tableau 2D de caractères dans le fichier `cst`, chaque caractère correspondant à une entité, un bloc ou une décoration différente.

A la base on voulait utiliser https://www.mapeditor.org/ pour creer la mape, exporter les données en JSON, puis les parse en 
Ocaml, mais on a pas eu le temps, et ceci a limité un peu nos capacités de creation de la map.

On a plusieurs objets de décoration, qui n’ont pas de collision.  
On a aussi un arrière-plan avec un effet de *parallax*, ce qui donne une impression de profondeur en bougeant avec le joueur.

### Optimisation avec le système `On_screen`
Ce système nous permet d’actualiser uniquement les entités nécessitant de gros calculs (notamment les collisions) si elles sont visibles à l’écran.  
On évite donc de les dessiner, bouger ou gérer les collisions inutilement.

Cela a largement amélioré les performances, mais a aussi introduit quelques bugs.

## Difficultés / Bugs

On a quelques bugs non résolus dans le code, qui ne cassent pas totalement le jeu mais restent présents.  
On n’a juste pas eu le temps de les corriger, ou pas compris complètement leur origine.

1. Quand le joueur est sur un terrain plat, parfois en avançant, il semble se coincer très légèrement au bord des blocs.

2. En cas de comportements extrêmes avec le système de collision (vitesse très élevée, joueur coincé entre blocs, etc.), le jeu peut complètement se bloquer et tout est envoyé dans le coin supérieur gauche de l’écran.  
   (Ce bug est très rare et on ne comprend pas exactement pourquoi tout se regroupe là-bas.)

3. La version SDL a des problèmes avec la fonction `unregister`. Quand on *unregister* beaucoup d’entités, un *segfault* peut finir par se produire.  
   (On a vérifié : on ne *unregister* ou *register* jamais deux fois la même entité.)  
   Cependant, la version JS ne rencontre aucun souci. Du coup, on a désactivé le système de checkpoint pour SDL.

4. Avec l’optimisation basée sur l’écran, si certains blocs précis ne sont pas pris en compte, les entités proches des bords peuvent tomber en dehors de la map.  
   (Ça reste très rare.)

## Modes de travail

On a surtout travaillé ensemble sur un seul ordi, pendant les séances de PFA dédiées.  
Mais vers la fin du projet, on a commencé à se partager les tâches, ce qui explique pourquoi une partie des commits vient majoritairement d’un seul compte.
