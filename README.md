# 🎵 Music Streaming Analysis — Spotify Dataset

A data analytics project analyzing 100,000+ Spotify tracks to uncover
listening patterns, genre trends, and audio feature insights.

---

## 📌 Problem Statement

What makes a song popular on Spotify? Which genres dominate streaming?
How has music evolved over the decades? This project answers these questions
using real Spotify data and translates findings into actionable insights.

---

## 📦 Dataset

- **Source:** [Kaggle — Spotify Tracks Dataset](https://www.kaggle.com/datasets/maharshipandya/-spotify-tracks-dataset)
- **Size:** ~114,000 tracks across 125 genres
- **Key Columns:**
  - `track_name`, `artists`, `track_genre`
  - `popularity` (0–100 score)
  - `danceability`, `energy`, `valence`, `tempo`, `loudness`
  - `duration_ms`, `explicit`, `track_album_release_date`

---

## 🛠️ Tech Stack

| Layer         | Tool                          |
|---------------|-------------------------------|
| Data Cleaning | Python (Pandas, NumPy)        |
| Analysis      | Python + SQL (PostgreSQL)     |
| Visualization | Matplotlib, Seaborn, Plotly   |
| Version Control | GitHub                      |

---

## 🧹 Data Cleaning Steps

1. Removed null values and duplicate records
2. Converted duration from milliseconds to minutes
3. Extracted release year from date column
4. Filtered out tracks with 0 popularity and extreme durations
5. Standardized genre names (lowercase, stripped whitespace)

---

## 📊 Analysis Performed

### Artist Analysis
- Top 10 artists by average popularity
- Most prolific artists by track count
- Artists dominating multiple genres

### Genre Analysis
- Top genres by popularity score
- Genre-wise audio feature comparison
- Genre market share distribution

### Audio Feature Analysis
- Correlation heatmap across all features
- Audio features of high vs low popularity tracks
- Mood classification (Euphoric / Aggressive / Peaceful / Melancholic)

### Time Trend Analysis
- Song duration trend from 1960–2023
- Year-over-year energy and danceability shifts
- Top tracks per year using window functions

---

## 💡 Key Insights

1. **Pop and Dance** genres consistently score highest in popularity
2. **Song duration has dropped** significantly post-2015 — shorter, hook-driven tracks dominate
3. **Danceability + Energy** are stronger predictors of popularity than valence (mood) alone
4. **Explicit tracks** tend to score slightly higher in popularity on average
5. **Music has become louder and more energetic** over the decades — a trend called the "Loudness War"
6. **Euphoric tracks** (high energy + positive mood) have the highest average popularity score

---

## 📁 Project Structure

```
music_streaming_analysis/
│
├── analysis.py          # Main Python EDA script
├── queries.sql          # All SQL queries (basic → advanced)
├── README.md            # This file
│
└── outputs/             # Auto-generated charts
    ├── 01_top_artists.png
    ├── 02_top_genres.png
    ├── 03_correlation_heatmap.png
    ├── 04_duration_trend.png
    ├── 05_energy_vs_popularity.html
    ├── 06_danceability_distribution.png
    ├── 07_popularity_distribution.png
    └── 08_explicit_popularity.png
```

---

## ▶️ How to Run

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/music-streaming-analysis

# 2. Install dependencies
pip install pandas numpy matplotlib seaborn plotly

# 3. Download dataset from Kaggle and place in project folder
#    Rename it to: spotify_tracks.csv

# 4. Create outputs folder
mkdir outputs

# 5. Run the analysis
python analysis.py
```

---

## 🔗 Connect

Made by Ayush Singh

