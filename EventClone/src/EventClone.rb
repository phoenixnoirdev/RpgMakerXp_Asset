#==============================================================================
# ** EventClone
#------------------------------------------------------------------------------
# Ce script permet de cloner un événement existant sur la carte et de le
# placer à une position spécifiée.
#
# Auteur: Phoenixnoir
#
# Contributions:
#   [Ton nom/pseudo si tu as contribué]
#
# Créé le: 2025-04-01 - 18:32:54
# Mis à jour le: 2025-04-02 - 03:38:30
#
# Description:
# Ce script fournit une fonction pour cloner un événement de la carte actuelle
# et créer une nouvelle instance à des coordonnées spécifiées. Il inclut
# également une option pour activer/désactiver les logs de débogage.
#
# Fonctionnalités:
# - Clonage d'un événement existant sur la carte.
# - Placement du clone à des coordonnées X et Y spécifiées.
# - Option pour activer/désactiver les logs de débogage dans un fichier.
#
# Utilisation:
# Pour cloner un événement, appelez la fonction suivante dans un script :
#   $game_map.spawn_event(original_event_id, x, y)
# Où :
#   original_event_id : L'ID de l'événement à cloner sur la carte.
#   x               : La coordonnée X où le clone sera placé.
#   y               : La coordonnée Y où le clone sera placé.
#
# Configuration:
# - La variable globale $enable_event_cloning_logs permet d'activer ou
#   de désactiver les logs de débogage. Définissez-la à true pour activer
#   les logs et à false pour les désactiver.
#
# Notes:
# - Assurez-vous que l'événement avec l'ID spécifié existe sur la carte.
# - Le clone aura les mêmes pages d'événement que l'original.
# - Utiliser le script sur des événements fixe, immobile ou invisible.
#
# Crédits:
# Si vous utilisez ce script dans votre projet, merci de créditer Phoenixnoir.
#
# Lien:
# https://github.com/phoenixnoirdev/RpgMakerXp_Asset
#
# Wiki:
# https://github.com/phoenixnoirdev/RpgMakerXp_Asset/wiki/EventClone
#==============================================================================


# Définir à true pour activer les logs, false pour les désactiver
$enable_event_cloning_logs = false

class Game_Map
  def initialize
    @spawned_events = {}
  end

  def spawn_event(original_event_id, x, y)
    # Vérifier si l'événement a déjà été cloné à cette position
    if @spawned_events[[original_event_id, x, y]]
      log("Cet événement (ID: #{original_event_id}) a déjà été cloné à la position (#{x}, #{y}). Aucune action effectuée.")
      return
    end

    log("Tentative de clonage de l'événement (ID: #{original_event_id}) en (#{x}, #{y})")

    original_event = @events[original_event_id]
    unless original_event
      log("Erreur : L'événement avec l'ID #{original_event_id} n'existe pas sur cette carte.")
      return
    end

    log("Événement original (ID: #{original_event_id}) trouvé, clonage en cours...")

    # Log de l'état du déplacement de l'événement original avant le clonage
    log("Événement original (ID: #{original_event_id}) - Déplacement actif avant clonage : #{original_event.move_route_forcing}")

    # Trouver un nouvel ID unique pour l'événement sur la carte
    new_event_id = (@events.keys.max || 0) + 1
    log("Nouvel ID généré pour l'événement cloné : #{new_event_id}")

    original_event_data = original_event.instance_variable_get(:@event)
    if original_event_data.nil?
      log("Erreur : @event est nil pour l'événement original, impossible de copier les pages.")
      return
    end

    log("Pages de l'événement original trouvées : #{original_event_data.pages ? original_event_data.pages.size : 0}")

    if original_event_data.pages.nil? || original_event_data.pages.empty?
      log("L'événement original (ID: #{original_event_id}) ne contient aucune page à cloner.")
      return
    end

    new_pages = original_event_data.pages.map do |page|
      new_page = page.dup
      # Clonage explicite de la liste des commandes
      new_page.list = page.list.map do |command|
        command.dup
      end rescue []
      new_page
    end

    log("Toutes les pages ont été copiées avec succès.")

    # Création du nouvel événement
    new_rpg_event = RPG::Event.new(x, y)

    # Assigner le nom de l'événement original avec un suffixe pour éviter les conflits
    original_name = original_event_data.name rescue "Événement Cloné"
    new_rpg_event.name = "#{original_name} (Cloné)"

    # Assigner les pages clonées
    new_rpg_event.pages = new_pages

    # Ajout du nouvel événement sur la carte
    @events[new_event_id] = Game_Event.new(@map_id, new_rpg_event)
    log("Nouvel événement ajouté à la carte avec l'ID #{new_event_id} à la position (#{x}, #{y}).")

    if new_rpg_event.pages.any?
      first_page = new_rpg_event.pages[0]
      if first_page
        log("Propriétés de la première page de l'événement cloné (ID: #{new_event_id}):")
        log("Trigger: #{first_page.trigger}") # 0: Action Button, 1: Player Touch, 2: Event Touch, 3: Auto, 4: Parallel
        # Ajout des logs pour les conditions
        log("Condition Interrupteur A: #{first_page.condition.switch1_valid ? $game_switches[first_page.condition.switch1_id] : 'Non défini'}")
        log("Condition Interrupteur B: #{first_page.condition.switch2_valid ? $game_switches[first_page.condition.switch2_id] : 'Non défini'}")
        log("Condition Variable: #{first_page.condition.variable_valid ? "#{$game_variables[first_page.condition.variable_id]} >= #{first_page.condition.variable_value}" : 'Non défini'}")
        # Ajoute d'autres conditions si nécessaire
      else
        log("La première page de l'événement cloné (ID: #{new_event_id}) est nil.")
      end
    else
      log("L'événement cloné (ID: #{new_event_id}) n'a aucune page.")
    end

    # Marquer cet événement comme déjà cloné à cette position
    @spawned_events[[original_event_id, x, y]] = true

    # Rafraîchir la carte pour afficher le nouvel événement
    refresh
    log("Carte rafraîchie.")

    # Log de l'état du déplacement de l'événement original après le clonage
    log("Événement original (ID: #{original_event_id}) - Déplacement actif après clonage : #{original_event.move_route_forcing}")

    log("Événement (ID: #{original_event_id}) cloné en (#{x}, #{y}) avec l'ID #{new_event_id}.")
  end

  # Fonction de log qui écrit dans un fichier Debug.log
  def log(message)
    if $enable_event_cloning_logs
      File.open("Debug.log", "a") do |file|
        file.puts("[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{message}")
      end
    end
  end
end