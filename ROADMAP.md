# ROADMAP.md — DRAEVEN

## Comment reprendre une session avec Claude
1. Ouvre une nouvelle conversation.
2. Colle le contenu de `GAME_DESIGN.md` et de ce fichier.
3. Dis : « On reprend, voici l'état du projet. » Précise la prochaine étape non cochée.
4. En fin de session, demande à Claude de mettre à jour les cases cochées et le journal.
5. Colle aussi les fichiers que tu veux modifier **depuis ton dépôt GitHub** (c'est la version de référence).

## Phase 0 — Fondations
- [x] Idée, genre, univers, ton, boss final définis
- [x] Choix du moteur (Godot 3.6.2, 3D low-poly)
- [x] Nom du jeu choisi : DRAEVEN
- [x] Logo et icône de l'application (lame bicolore or et noir, icône Android en place)
- [ ] Écran-titre : lame, nom DRAEVEN, bouton Jouer (v0.3 écrite, à valider)
- [x] Dépôt GitHub créé
- [x] Prototype envoyé et compilé en APK par GitHub Actions
- [x] APK installé et testé sur le téléphone (déplacement + caméra OK, fluide)
- [ ] Godot 3.6 testé sur le PC Windows 7 (facultatif, la compilation se fait dans le cloud)

## Phase 1 — Prototype jouable
- [x] Déplacement + caméra suivant le joueur
- [x] Personnage humain low-poly animé (validé sur téléphone)
- [x] Boutons tactiles : coup, esquive (validé sur téléphone)
- [x] Un ennemi simple avec IA de poursuite et attaque (validé : 5 ennemis vaincus au premier test)
- [ ] Barre de vie validée ; KO et réapparition encore à valider
- [ ] Première petite carte avec collisions soignées (bâtiments, trottoirs)

## Phase 2 — Premier quartier
- [ ] Création de personnage (nom, apparence, passé, Proche)
- [ ] Quartier avec bâtiments, routes, PNJ
- [ ] Système de dialogues
- [ ] Premières quêtes + journal de quêtes
- [ ] Sauvegarde / chargement

## Phase 3 — Combat complet
- [ ] Mêlée avec combos, parade
- [ ] Armes à feu, visée, munitions
- [ ] 3 types d'ennemis, premier mini-boss
- [ ] Armes et équipements

## Phase 4 — Conduite
- [ ] Voiture jouable, caméra de conduite
- [ ] Monter / descendre, dégâts
- [ ] Moto, puis bateau
- [ ] Circulation simple

## Phase 5 — RPG
- [ ] XP, arbres de compétences
- [ ] Argent, boutiques, inventaire
- [ ] Réputation des factions
- [ ] Propriétés / repaires

## Phase 6 — Monde et histoire
- [ ] Agrandissement de la carte (plusieurs quartiers et régions)
- [ ] Histoire principale en actes
- [ ] Le Proche présent dans la narration
- [ ] Cycle jour/nuit, météo
- [ ] Donjons : repaires, entrepôts, manoirs

## Phase 7 — Boss final
- [ ] Arène et lieux du dernier niveau
- [ ] Combat en phases, très difficile
- [ ] Fins et mode difficile

## Phase 8 — Multijoueur
- [ ] Choix du service d'authentification
- [ ] Inscription / connexion avec pseudo
- [ ] Serveur et synchronisation
- [ ] Missions coopératives

## Phase 9 — Finitions
- [ ] Musique, sons, interface soignée
- [ ] Optimisation mobile
- [ ] Tests, équilibrage, correction de bugs

## Notes techniques (apprises en route)
- Compilation : image Docker `barichello/godot-ci:3.6.2` (la 3.5.3 n'existe pas).
- Le workflow cherche lui-même les templates d'export et le chemin de Java.
- `project.godot` doit contenir `vram_compression/import_etc=true` (sinon l'export Android échoue).
- Les personnages sont des **humains** low-poly (script `Humanoid.gd`), pas des cubes.
- Les boutons tactiles gèrent plusieurs doigts (un pour bouger, un pour attaquer).
- En Godot 3 on écrit `rand_range` (`randf_range` n'existe qu'en Godot 4) : attention aux tutoriels Godot 4.
- La clé de signature change à chaque compilation : désinstaller l'ancienne version avant d'installer un nouvel APK.
- Journal de démarrage `user://boot.log` : si le jeu se fige, au lancement suivant l'écran affiche la dernière étape atteinte (texte jaune).
- La compilation contrôle maintenant chaque script (`--check-only`) et lance un test de 6 s (`smoke_test.gd`) : si un script est cassé, aucun APK n'est fabriqué.
- Écran-titre : images pré-dessinées (`title_*.png`, `btn_play*.png`) ; le bouton Retour d'Android revient au titre depuis le jeu (`config/quit_on_go_back=false`).
- Icône : `icon.png`, `icon_192.png`, `icon_fg.png` (avant, transparent) et `icon_bg.png` (fond uni) ; le détourage de la lame vient de l'image générée par l'utilisateur.

## Journal
- 22/11/2026 : conception initiale, prototype v0.1 (déplacement 3D) compilé et testé sur téléphone après réglage du workflow.
- 22/11/2026 : v0.2 écrite (humains low-poly, coup, esquive, ennemis, barre de vie).
- 23/11/2026 : test de la v0.2 : écran noir puis téléphone bloqué. Une erreur trouvée (`randf_range`), qui n'explique pas à elle seule le blocage. v0.2.1 : correctif + journal de démarrage pour localiser la cause. Nom du jeu choisi : DRAEVEN.
- 23/11/2026 : nom d'application et identifiant Android passés à DRAEVEN (`com.draeven.game`), version 0.2.1, contrôle automatique des scripts ajouté à la compilation.
- 23/11/2026 : v0.2.1 validée sur téléphone (le jeu tourne, combat OK, 5 ennemis vaincus). Icône DRAEVEN (lame) installée sur le téléphone.
- 23/11/2026 : v0.3 écrite : écran-titre (lame, nom, bouton Jouer) et retour au titre avec le bouton Retour. Non encore testée.
