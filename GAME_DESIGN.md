# GAME_DESIGN.md — Projet « Soleil Noir » (titre provisoire)

> Document vivant. À coller au début de chaque nouvelle session avec Claude.
> Dernière mise à jour : 22/11/2026

## 1. Vision

Un **RPG d'action en monde ouvert, en 3D low-poly**, dans un État fictif, chaud et tentaculaire
(plages, marais, grandes villes néon, banlieues, arrière-pays). Le joueur crée son personnage
et gravit les échelons du monde criminel, de petite frappe à figure majeure.
Ton **sérieux et épique** : trahisons, loyautés, ascension et chute.

Objectif : faire **le meilleur jeu possible**, sans date limite. On avance par étapes jouables.

## 2. Piliers

1. **Un monde vivant à explorer** : quartiers distincts, activités, secrets, météo et cycle jour/nuit.
2. **Un combat d'action nerveux** (esquive, timing, ennemis variés, boss à phases), façon Zelda,
   avec mêlée et armes à feu.
3. **Un personnage à soi** : chaque joueur est différent (passé, style, compétences, choix).
4. **Conduire** : voitures, motos, bateaux ; la caméra s'adapte.
5. **Une histoire qui marque**, avec une trahison finale personnelle.

## 3. Règle de propriété intellectuelle

Univers **inspiré** par l'esprit des grands jeux criminels en monde ouvert, mais **100 % original** :
pas de noms, lieux, personnages, logos ou musiques d'œuvres existantes. Tout nom propre
(État, villes, gangs, personnages) est à inventer par nous.

## 4. Caméra (vue qui change)

- **À pied** : caméra en hauteur, en retrait, légèrement inclinée (type action-RPG).
- **En véhicule** : caméra derrière le véhicule, plus basse, qui s'éloigne avec la vitesse.
- **Combat de boss / cinématiques** : caméra dirigée, plans plus dramatiques.
- Transitions toujours fluides (interpolation), jamais de coupure brutale en jeu.

## 5. Création du personnage

À l'inscription / nouvelle partie :
- **Pseudo** (unique en ligne), nom du personnage, apparence (low-poly : corps, coiffure, vêtements, couleurs).
- **Passé** (choix qui donne des bonus de départ et des dialogues propres) : ex. ancien mécano,
  ex-militaire, enfant des rues, étudiant ruiné…
- **Style de jeu** qui oriente les compétences : bagarreur, tireur, discret, conducteur.
- **Le Proche** : la personne de confiance du joueur (mentor, meilleur ami, frère/sœur de cœur),
  avec **son nom, son apparence et leur histoire commune** choisis par le joueur. Voir §9.

« Tous les joueurs sont différents » : passé, compétences qui évoluent différemment,
réputation et décisions qui modifient quêtes, dialogues et fins.

## 6. Combat

- Temps réel, en 3D, commandes tactiles : joystick, bouton attaque, bouton esquive, visée/tir.
- **Mêlée** : poings, batte, couteau… combos courts, timing d'esquive/parade.
- **Armes à feu** : visée assistée sur mobile, munitions limitées, recul, rechargement.
- **Ennemis** : types aux comportements différents (brute, tireur, groupe, élite).
- **Boss** : attaques à motifs lisibles, phases multiples, mécaniques propres.
- Pas de gore explicite ; ton dramatique mais pas gratuit.

## 7. Conduite

- Voitures, motos, bateaux (dans cet ordre de priorité).
- Physique arcade (agréable avant d'être réaliste), dégâts, carburant optionnel, personnalisation.
- Circulation et piétons simples au début, enrichis ensuite.

## 8. Progression

- XP et compétences par arbres (combat, conduite, discrétion, charisme).
- Argent, boutiques, armes, véhicules, propriétés / repaires.
- Réputation auprès de plusieurs factions (gangs, police, civils).
- Quêtes principales (histoire), secondaires, contrats, activités annexes.
- Sauvegarde locale ; synchronisation en ligne à la phase multijoueur.

## 9. Histoire et boss final (esquisse)

Saga en actes : arrivée et petites combines → montée en puissance → guerre entre factions →
sommet et soupçons → **trahison** → affrontement final.

**Le boss final est le Proche choisi par le joueur.** Il accompagne le joueur toute la partie
(missions, conseils, scènes de confiance), puis le trahit. Comme chaque joueur l'a créé,
la trahison est personnelle.

Combat final, **très difficile** :
- plusieurs phases, dans plusieurs lieux liés à leur histoire commune ;
- il réutilise « tout ce qu'il t'a appris » (ses attaques reprennent les techniques enseignées) ;
- s'adapte en partie au style du joueur (si tu abuses du tir, il se met à couvert, etc.) ;
- mode « difficile » optionnel, récompenses et fin alternative.

## 10. Multijoueur (Phase 2, après le solo complet)

- Compte avec **pseudo** créé à l'inscription, via un **service d'authentification existant**
  (pas de mots de passe stockés « maison »).
- **Missions coopératives** à 2–4 joueurs, invitation par pseudo.
- Architecture : serveur dédié ou hébergé (coût à étudier à ce moment-là).
- Le solo est conçu dès le départ pour ne pas bloquer cette évolution
  (séparation données joueur / logique de jeu, identifiants uniques).

## 11. Choix techniques

| Sujet | Choix |
|---|---|
| Moteur | **Godot 3.5.x** (GLES2), langage GDScript |
| Pourquoi | Tourne sur Windows 7, léger, bon pour la 3D low-poly |
| Style visuel | 3D low-poly, couleurs franches, peu de textures |
| Build | **GitHub Actions** → APK debug téléchargeable |
| Cible | Android, orientation paysage |
| Mémoire du projet | Ce dépôt (`GAME_DESIGN.md`, `ROADMAP.md`) |

Modèles 3D : on les fabriquera avec des formes simples (Godot ou Blender si le PC le permet),
ou assets libres (licences CC0 à vérifier une par une).

## 12. Questions ouvertes

- Nom de l'État, des villes, des factions, titre définitif du jeu.
- Taille du premier quartier jouable.
- Doublage / texte seulement (je recommande texte seulement au début).
- Monétisation : aucune pour l'instant (jeu personnel).
- Âge/contenu : définir une limite de contenu claire pour le ton (violence, langage).
