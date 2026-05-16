module ApplicationHelper
  def patient_initials(name)
    name.to_s.split.first(2).map { |w| w[0].upcase }.join
  end

  def patient_avatar_color(name)
    colors = %w[bg-blue-200 bg-emerald-200 bg-violet-200 bg-orange-200 bg-pink-200 bg-teal-200]
    # String#sum retourne la somme des codes ASCII du nom. Le modulo garantit
    # un index valide et stable : le même nom aura toujours la même couleur.
    colors[name.to_s.sum % colors.length]
  end

  def category_badge_color(category)
    {
      "Anatomie"    => "bg-green-100 text-green-800",
      "Pathologies" => "bg-orange-100 text-orange-800",
      "Latin"       => "bg-violet-100 text-violet-800",
      "Traitement"  => "bg-blue-100 text-blue-800",
      "Mes termes"  => "bg-amber-100 text-amber-800"
    }.fetch(category.to_s, "bg-gray-100 text-gray-700")
  end

  def category_dot_color(category)
    {
      "Anatomie"    => "bg-green-500",
      "Pathologies" => "bg-orange-500",
      "Latin"       => "bg-violet-500",
      "Traitement"  => "bg-blue-500",
      "Mes termes"  => "bg-amber-600"
    }.fetch(category.to_s, "bg-gray-400")
  end
end
