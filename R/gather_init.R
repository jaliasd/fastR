#' Reshape budget columns long for Initiatives tab
#'
#' @param df FAST data frame to gather
#' @param filepath full file path for the COP19 FAST
#'
#' @export
#' @importFrom magrittr %>%


gather_init <- function(df, filepath){
  #gather
  df <- df %>%
    tidyr::gather(budget_code, amt,
                  dplyr::starts_with("bilat_"), dplyr::starts_with("init2_"), dplyr::starts_with("init3_"),
                  na.rm  = TRUE) %>%
    dplyr::mutate(amt = stringr::str_remove(amt, "-"),
                  amt = as.double(amt)) %>%
    dplyr::filter(amt > 0)

  #combine iniatives into type column
  if(is_oldformat(filepath)) {
    #df <- dplyr::mutate(df, initiative_type = dplyr::coalesce(initiative2, initiative1))
    df <- df %>%
      dplyr::mutate_at(dplyr::vars(initiative1, initiative2), ~ dplyr::na_if(., 0)) %>%
      tidyr::unite(initiative_type, initiative1, initiative2, sep = "/") %>%
      dplyr::mutate(initiative_type = stringr::str_remove_all(initiative_type, "/NA"),
                    initiative_type = stringr::str_remove_all(initiative_type, "Bilateral 19/"))
  } else {
    #df <- dplyr::mutate(df, initiative_type = dplyr::coalesce(initiative3, initiative2, initiative1))
    df <- df %>%
      dplyr::mutate_at(dplyr::vars(initiative1, initiative2, initiative3), ~ dplyr::na_if(., 0)) %>%
      tidyr::unite(initiative_type, initiative1, initiative2, initiative3, sep = "/") %>%
      dplyr::mutate(initiative_type = stringr::str_remove_all(initiative_type, "/NA"),
                    initiative_type = stringr::str_remove_all(initiative_type, "Bilateral 19/"))

  }

  #remove initiative columns and references in budget code
  df <- df %>%
    #dplyr::select(-dplyr::starts_with("initiative")) %>%
    dplyr::mutate(budget_code = stringr::str_remove(budget_code, "bilat_|init2_|init3_"))

  #breakout program areas
  # df <- df %>%
  #   dplyr::mutate(prog_prev = dplyr::case_when(stringr::str_detect(budget_code, "prev") ~ "X"),
  #                 prog_ct   = dplyr::case_when(stringr::str_detect(budget_code, "ct")   ~ "X"),
  #                 prog_se   = dplyr::case_when(stringr::str_detect(budget_code, "se")   ~ "X"),
  #                 prog_asp  = dplyr::case_when(stringr::str_detect(budget_code, "asp")  ~ "X"),
  #                 prog_hts  = dplyr::case_when(stringr::str_detect(budget_code, "hts")  ~ "X"))
  #clean budget code
  df <- df %>%
    dplyr::mutate(budget_code = stringr::str_remove(budget_code, "\\..*$") %>% toupper(.),
                  budget_code = ifelse(budget_code == "APPLIEDPIPELINE", "Applied Pipeline", budget_code))

  #reorder $ to back
  df <- dplyr::select(df, -amt, dplyr::everything())

  return(df)
}
