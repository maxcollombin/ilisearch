#!/bin/bash

base_url="https://models.geo.admin.ch"
index_url="$base_url/ilimodels.xml"
output_file="models.csv"
search_keyword="ABSTRACT"  # Modifier ici le mot-clé recherché

echo "Téléchargement de la liste des modèles depuis $index_url..."
xml_content=$(curl -s "$index_url")

if [[ -z "$xml_content" ]]; then
    echo "Erreur : Impossible de récupérer ilimodels.xml"
    exit 1
fi

echo "Extraction des chemins de fichiers .ili..."
files=$(echo "$xml_content" | grep -oP '(?<=<File>).*?(?=</File>)')

if [[ -z "$files" ]]; then
    echo "Aucun fichier .ili trouvé dans ilimodels.xml"
    exit 1
fi

echo "Sauvegarde des résultats dans $output_file"
echo "Fichiers contenant '$search_keyword':" > "$output_file"

for file in $files; do
    # Ignorer les fichiers dans "obsolete" ou "replaced"
    if [[ "$file" =~ (obsolete|replaced) ]]; then
        echo "Ignoré : $file"
        continue
    fi

    full_url="$base_url/$file"
    echo "Analyse de $full_url..."

    if curl -s "$full_url" | grep -q "$search_keyword"; then
        echo "$search_keyword trouvé dans : $full_url"
        echo "$full_url" >> "$output_file"
    fi
done

echo "Analyse terminée. Résultats enregistrés dans $output_file."
