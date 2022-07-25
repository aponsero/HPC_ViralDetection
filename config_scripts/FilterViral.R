# script to merge viral outputs in a unique table
library(tidyverse)

args<-commandArgs(TRUE)

## Input files and directories
DVF_checkV_file=args[1]
VS2_checkV_file=args[2]
coverage_file=args[3]
name=args[4]

DVF_checkV <- read_tsv(DVF_checkV_file) %>% 
  mutate(DVF=TRUE)
VS2_checkV <- read_tsv(VS2_checkV_file) %>% 
  rename("VS_contig_name"="contig_id") %>%
  separate(VS_contig_name, into=c("contig_id", "VS_annotation"), sep="\\|\\|", remove=FALSE) %>%
  mutate(VS2=TRUE)
coverage <- read_tsv(coverage_file) %>% 
  rename("ID"=`#ID`) %>%
  separate(ID, into=c("contig_id", "flag", "multi", "len"), sep=" ", remove = FALSE)

# selection CheckV 
DVF_checkV <- DVF_checkV %>% filter((viral_genes>0) | (host_genes==0))
VS2_checkV <- VS2_checkV %>% filter((viral_genes>0) | (host_genes==0))

# merge DVF and VS2 (priority on VS2)
match_VS2 <- VS2_checkV %>% select(contig_id) %>% pull()

addition_DVF <- DVF_checkV %>% filter(contig_id %in% match_VS2) %>%
  select(contig_id, DVF)
merge_table <- left_join(VS2_checkV, addition_DVF)

found_DVF <- DVF_checkV %>% filter(!contig_id %in% match_VS2)
merge_table <- full_join(merge_table, found_DVF) 

merge_table <- merge_table %>%
  mutate(DVF=ifelse(is.na(DVF), FALSE, DVF)) %>%
  mutate(VS2=ifelse(is.na(VS2), FALSE, VS2))

# coverage info
merge_table <- left_join(merge_table, coverage) 
merge_table <- merge_table %>% filter(Median_fold>=5) %>%
  relocate(contig_id, contig_length, DVF, VS2)

# print tables
total_table <- paste(name, "selection1.csv", sep="_")
write_csv(merge_table, total_table)

#DVF_table <- paste(name, "DVF_checkV.csv", sep="_")
#write_csv(DVF_checkV, DVF_table)

#VS2_table <- paste(name, "VS2_checkV.csv", sep="_")
#write_csv(VS2_checkV, VS2_table)


