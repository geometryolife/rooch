// Copyright (c) RoochNetwork
// SPDX-License-Identifier: Apache-2.0

use anyhow::Result;
use rooch_config::indexer_config::IndexerConfig;
use rooch_config::{BaseConfig, RoochOpt};
use rooch_indexer::indexer_reader::IndexerReader;
use rooch_indexer::IndexerStore;
use rooch_types::rooch_network::RoochChainID;
use std::path::PathBuf;
use std::sync::Arc;

pub mod rebuild;

pub const BATCH_SIZE: usize = 5000;
fn init_indexer(
    base_data_dir: Option<PathBuf>,
    chain_id: Option<RoochChainID>,
) -> Result<(IndexerStore, IndexerReader)> {
    // Reconstruct RoochOpt
    let opt = RoochOpt::new_with_default(base_data_dir, chain_id);

    //Init store
    let base_config = BaseConfig::load_with_opt(&opt)?;
    let arc_base_config = Arc::new(base_config);
    let mut indexer_config = IndexerConfig::default();
    indexer_config.merge_with_opt_with_init(&opt, Arc::clone(&arc_base_config), false)?;

    let indexer_db_path = indexer_config.get_indexer_db();
    let indexer_store = IndexerStore::new(indexer_db_path.clone())?;
    let indexer_reader = IndexerReader::new(indexer_db_path)?;

    Ok((indexer_store, indexer_reader))
}
