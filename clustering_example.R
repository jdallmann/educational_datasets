# ==============================================================================
# LECTURE DEMO: Retail Product Segmentation via Clustering in R (Tidyverse)
# Dataset: MASS::UScereal (65 CPG Cereal Brands, 8 Continuous Nutritional Metrics)
# Methods: K-Means, Agglomerative (Ward's), and Divisive (DIANA)
# ==============================================================================

# 1. Load Packages & Data ------------------------------------------------------
library(tidyverse)
library(broom)    # For tidying k-means outputs into tibbles
library(cluster)  # Built-in package for agnes() and diana()

# Load UScereal from MASS without attaching MASS (avoids masking dplyr::select)
data("UScereal", package = "MASS")

# 2. Data Preparation, Feature Selection & Standardization ---------------------
# Retain brand names and categorical merchandising columns for post-hoc profiling,
# and isolate the 8 continuous nutritional variables for distance calculations:
#   calories, protein (g), fat (g), sodium (mg), 
#   fibre (g), carbo (g), sugars (g), potassium (mg)

set.seed(1234)
cereal_raw <- UScereal %>%
  rownames_to_column(var = "brand") %>%
  as_tibble() %>%
  drop_na() %>%
  sample_n(30)

num_vars <- c("calories", "protein", "fat", "sodium", "fibre", "carbo", "sugars", "potassium")

# Standardize continuous features to z-scores (mean = 0, sd = 1)
# Wrapping scale() in as.numeric() strips matrix attributes that break dplyr/ggplot
cereal_scaled <- cereal_raw %>%
  select(brand, all_of(num_vars)) %>%
  mutate(across(-brand, ~ as.numeric(scale(.x))))

# Verify mean = 0 and sd = 1 across all 8 nutritional features
cereal_scaled %>%
  summarise(across(-brand, list(mean = ~ round(mean(.x), 2), sd = sd)))

# Extract a numeric matrix with brand rownames for clustering functions
cereal_mat <- cereal_scaled %>%
  column_to_rownames(var = "brand") %>%
  as.matrix()

# Pre-compute the Euclidean distance matrix (used in Hierarchical methods)
dist_euc <- dist(cereal_mat, method = "euclidean")


# ==============================================================================
# PART 1: K-Means Clustering
# ==============================================================================
# Statistician's Note: K-means relies on random starting centroids and converges 
# to local optima. Always set a seed AND set nstart = 25 so R runs 25 random 
# initializations and retains the one with the lowest total within-cluster variance.

set.seed(2026)

# 1A. Evaluate K = 1 to 10 for the Elbow Plot using purrr + broom
k_search <- tibble(k = 1:10) %>%
  mutate(
    k_model = map(k, ~ kmeans(cereal_mat, centers = .x, nstart = 25, iter.max = 100)),
    glanced = map(k_model, glance)
  ) %>%
  unnest(glanced)

# Plot Total Within-Cluster Sum of Squares (tot.withinss)
ggplot(k_search, aes(x = k, y = tot.withinss)) +
  geom_line(linewidth = 1, color = "steelblue") +
  geom_point(size = 3, color = "steelblue") +
  scale_x_continuous(breaks = 1:10) +
  labs(
    title = "K-Means Elbow Plot (US Cereal Product Segmentation)",
    subtitle = "k = 4 captures the primary nutritional product tiers",
    x = "Number of Clusters (k)",
    y = "Total Within-Cluster Sum of Squares"
  ) +
  theme_minimal()

# 1B. Fit Final K-Means Model (k = 4)
km_fit <- kmeans(cereal_mat, centers = 4, nstart = 25)

# View cluster centroids (in standardized z-score units)
tidy(km_fit)

# Append cluster assignments back to the tidy tibble
cereal_results <- augment(km_fit, cereal_scaled) %>%
  rename(cluster_kmeans = .cluster)


# ==============================================================================
# PART 2: Agglomerative Hierarchical Clustering (Bottom-Up, Ward's Method)
# ==============================================================================
# Statistician's Note: In base R's hclust(), ALWAYS use method = "ward.D2" 
# (which squares dissimilarities before updating, implementing true Ward's 
# minimum variance method) rather than "ward.D". Alternatively, cluster::agnes() 
# with method = "ward" implements true Ward's method and computes the 
# Agglomerative Coefficient (AC) to quantify clustering structure strength.

# 2A. Fit using base stats::hclust() with Ward's method
hc_ward <- hclust(dist_euc, method = "ward.D2")

# Plot dendrogram with k = 4 cut rectangles
plot(hc_ward, main = "Agglomerative Clustering of Cereals (Ward's D2)", xlab = "", sub = "", cex = 0.6)
rect.hclust(hc_ward, k = 4, border = 2:5)

# 2B. Fit using cluster::agnes() to obtain the Agglomerative Coefficient
agnes_ward <- agnes(cereal_mat, metric = "euclidean", method = "ward")
cat("Agglomerative Coefficient:", round(agnes_ward$ac, 3), "\n") # Closer to 1 = strong structure

# Cut tree into k = 4 clusters and add to our tidy results tibble
cereal_results <- cereal_results %>%
  mutate(cluster_agglom = factor(cutree(hc_ward, k = 4)))


# ==============================================================================
# PART 3: Divisive Hierarchical Clustering (Top-Down, DIANA)
# ==============================================================================
# Statistician's Note: DIANA (DIvisive ANAlysis) starts with all 65 cereals in 
# a single root cluster and recursively splits the cluster with the largest 
# diameter. Notice how DIANA immediately isolates the extreme high-fiber bran 
# cereals (100% Bran, All-Bran, All-Bran with Extra Fiber) at the very first split!

diana_fit <- diana(cereal_mat, metric = "euclidean")

# Check the Divisive Coefficient (DC) - analogous to AC in agnes()
cat("Divisive Coefficient:", round(diana_fit$dc, 3), "\n")

# Plot the Divisive Dendrogram
pltree(diana_fit, main = "Divisive Hierarchical Clustering of Cereals (DIANA)", cex = 0.6, xlab = "", sub = "")
rect.hclust(diana_fit, k = 4, border = 2:5)

# Cut divisive tree at k = 4 and add to the tidy results tibble
cereal_results <- cereal_results %>%
  mutate(cluster_divisive = factor(cutree(as.hclust(diana_fit), k = 4)))


# ==============================================================================
# PART 4: Business Profiling & External Merchandising Validation
# ==============================================================================

# 4A. Profile Clusters in Original Nutritional Units + Sample Brands
# Typical 4-Cluster Breakdown:
#   - High-Fiber Bran Tier (100% Bran, All-Bran, Bran Buds)
#   - Dense / High-Calorie / Nut & Granola Tier (Grape-Nuts, 100% Natural Bran, Great Grains)
#   - High-Sugar Kids Tier (Apple Jacks, Cocoa Puffs, Froot Loops, Lucky Charms)
#   - Light / Low-Sugar Staple Tier (Cheerios, Corn Flakes, Rice Krispies, Special K)

cereal_profiled <- cereal_raw %>%
  left_join(
    select(cereal_results, brand, cluster_kmeans, cluster_agglom, cluster_divisive),
    by = "brand"
  )

cereal_profiled %>%
  group_by(cluster_kmeans) %>%
  summarise(
    n_brands = n(),
    across(all_of(num_vars), ~ round(mean(.x), 1)),
    sample_brands = paste(head(brand, 3), collapse = ", ")
  )

# 4B. External Business Validation: Do Nutritional Clusters Map to Grocery Shelf Height?
# (Shelf 1 = Bottom/Kids Eye-Level, Shelf 2 = Middle, Shelf 3 = Top/Adult Eye-Level)
cereal_profiled %>%
  count(cluster_kmeans, shelf) %>%
  group_by(cluster_kmeans) %>%
  mutate(pct_on_shelf = round(100 * n / sum(n), 1)) %>%
  pivot_wider(
    id_cols = cluster_kmeans,
    names_from = shelf,
    values_from = pct_on_shelf,
    names_prefix = "shelf_",
    values_fill = 0
  )

# 4C. Visual Comparison in 2D Principal Component Space (Faceted ggplot)
pca_coords <- prcomp(cereal_mat) %>%
  augment(cereal_results)

pca_coords %>%
  pivot_longer(
    cols = starts_with("cluster_"),
    names_to = "method",
    values_to = "cluster",
    names_prefix = "cluster_"
  ) %>%
  mutate(method = recode(method,
                         "kmeans"   = "1. K-Means",
                         "agglom"   = "2. Agglomerative (Ward's)",
                         "divisive" = "3. Divisive (DIANA)"
  )) %>%
  ggplot(aes(x = .fittedPC1, y = .fittedPC2, color = cluster, label = brand)) +
  geom_point(size = 2.2, alpha = 0.85) +
  geom_text(vjust = -0.7, size = 2.3, show.legend = FALSE, check_overlap = TRUE) +
  facet_wrap(~ method) +
  labs(
    title = "Comparison of Clustering Algorithms in PCA Space (k = 4)",
    subtitle = "65 US Cereal Brands across 8 Standardized Nutritional Features",
    x = "Principal Component 1 (Overall Nutritional Density & Fiber)",
    y = "Principal Component 2 (Sugar & Simple Carbs vs. Protein/Minerals)",
    color = "Cluster ID"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")
