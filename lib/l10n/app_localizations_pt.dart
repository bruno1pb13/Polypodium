// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navMyPlants => 'Minhas Plantas';

  @override
  String get navSpecies => 'Espécies';

  @override
  String get navLocations => 'Localizações';

  @override
  String get navSoils => 'Solos';

  @override
  String get navSettings => 'Configurações';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Deletar';

  @override
  String get deleteAction => 'Excluir';

  @override
  String get save => 'Salvar';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get create => 'Criar';

  @override
  String get next => 'Próximo';

  @override
  String get back => 'Voltar';

  @override
  String get notNow => 'Agora não';

  @override
  String get all => 'Todos';

  @override
  String get optional => 'Opcional';

  @override
  String get requiredField => 'Campo obrigatório';

  @override
  String get requiredShort => 'Obrigatório';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get none => 'Nenhuma';

  @override
  String get defaultValue => 'Padrão';

  @override
  String get notInformed => 'Não informado';

  @override
  String get notAllowed => 'Não permitido.';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get share => 'Compartilhar';

  @override
  String get camera => 'Câmera';

  @override
  String get gallery => 'Galeria';

  @override
  String get rename => 'Renomear';

  @override
  String get reconnect => 'Reconectar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get migrate => 'Migrar';

  @override
  String get signIn => 'Entrar';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get positiveNumberRequired => 'Informe um número positivo';

  @override
  String get invalidNumber => 'Número inválido';

  @override
  String get nameRequired => 'Informe um nome';

  @override
  String get nameLabel => 'Nome';

  @override
  String get descriptionLabel => 'Descrição';

  @override
  String get introSkip => 'Pular';

  @override
  String get introGetStarted => 'Começar';

  @override
  String get introWelcomeTitle => 'Bem-vindo ao Polypodium';

  @override
  String get introWelcomeBody =>
      'Seu companheiro para cuidar da sua coleção de plantas.';

  @override
  String get introPlantsTitle => 'Acompanhe suas plantas';

  @override
  String get introPlantsBody =>
      'Cadastre cada planta com fotos, espécie, localização e solo, e mantenha todo o histórico em um só lugar.';

  @override
  String get introRemindersTitle => 'Lembretes de rega';

  @override
  String get introRemindersBody =>
      'Receba notificações quando for hora de regar, de acordo com as necessidades de cada espécie.';

  @override
  String get introRemindersTimeLabel => 'Lembrar às';

  @override
  String get introRemindersEnable => 'Ativar lembretes';

  @override
  String get introRemindersEnabled => 'Lembretes ativados!';

  @override
  String get introRemindersLaterNote =>
      'Você pode mudar isso quando quiser nas Configurações.';

  @override
  String get introSyncTitle => 'Seus dados, em todo lugar';

  @override
  String get introSyncBody =>
      'Tudo funciona offline. Conecte-se a um servidor depois para sincronizar entre dispositivos e fazer backup dos seus dados.';

  @override
  String get dateFormatPattern => 'dd/MM/yyyy';

  @override
  String daysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '$days dia',
    );
    return '$_temp0';
  }

  @override
  String errorGeneric(String error) {
    return 'Erro: $error';
  }

  @override
  String syncDownloaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novidades sincronizadas',
      one: '1 novidade sincronizada',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline => 'Sem conexão com o servidor — usando dados locais';

  @override
  String get pendingSync => 'Pendente de sincronização';

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get allSynced => 'Tudo sincronizado';

  @override
  String pendingEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos pendentes',
      one: '$count evento pendente',
    );
    return '$_temp0';
  }

  @override
  String get autoSync => 'Sincronização automática';

  @override
  String get autoSyncOnSubtitle =>
      'A cada 5 minutos (30 em economia de bateria no Android)';

  @override
  String get autoSyncOffSubtitle => 'Desativada — sincronize manualmente';

  @override
  String get localWorkspaceNoSync => 'Workspace local — não sincroniza';

  @override
  String get manageWorkspaces => 'Gerenciar workspaces';

  @override
  String get errorSessionExpired => 'Sessão expirada. Faça login novamente.';

  @override
  String get errorSyncReceive => 'Erro ao receber dados do servidor';

  @override
  String get errorSyncSend => 'Erro ao enviar dados para o servidor';

  @override
  String get errorNotAuthenticated => 'Não autenticado';

  @override
  String get errorServerUnavailable =>
      'Servidor não disponível ou URL inválida';

  @override
  String get errorAdminForbidden => 'Você não tem permissão de administrador.';

  @override
  String get errorLoginFailed => 'Falha ao autenticar';

  @override
  String get errorRegisterFailed => 'Falha ao criar conta';

  @override
  String get errorServerCommunication => 'Erro ao comunicar com o servidor';

  @override
  String get errorSpeciesInUse =>
      'Não é possível excluir uma espécie com plantas vinculadas.';

  @override
  String get errorSoilInUse =>
      'Não é possível excluir um solo com plantas vinculadas.';

  @override
  String get locationUnsupportedPlatform =>
      'Geolocalização não é suportada no desktop Linux.';

  @override
  String get locationServiceDisabled =>
      'O GPS está desativado. Ative-o e tente novamente.';

  @override
  String get locationPermissionDenied => 'Permissão de localização negada.';

  @override
  String get locationPermissionDeniedForever =>
      'Permissão de localização negada permanentemente. Habilite nas configurações do dispositivo.';

  @override
  String locationFetchError(String error) {
    return 'Não foi possível obter a localização: $error';
  }

  @override
  String get galleryPermissionDenied =>
      'Permissão negada para acessar a galeria';

  @override
  String get imageSavedToGallery => 'Imagem salva na galeria';

  @override
  String imageSaveError(String error) {
    return 'Erro ao salvar imagem: $error';
  }

  @override
  String shareError(String error) {
    return 'Erro ao compartilhar: $error';
  }

  @override
  String get saveToGallery => 'Salvar na galeria';

  @override
  String get irrigationChannelName => 'Irrigação';

  @override
  String get irrigationChannelDescription =>
      'Lembretes de irrigação das suas plantas';

  @override
  String get irrigationNotificationTitle => 'Hora de regar! 🌿';

  @override
  String irrigationNotificationBody(String nickname) {
    return '$nickname precisa ser regada hoje.';
  }

  @override
  String irrigationNotificationBodyMany(int count, String names) {
    return '$count plantas precisam ser regadas hoje: $names.';
  }

  @override
  String irrigationNotificationBodyCount(int count) {
    return '$count plantas precisam de água hoje.';
  }

  @override
  String get historyPlantAdded => 'Planta adicionada ao sistema:';

  @override
  String get historyFieldNickname => 'Apelido';

  @override
  String get historyFieldSpecies => 'Espécie';

  @override
  String get historyFieldSoil => 'Solo';

  @override
  String get historyFieldLocation => 'Localização';

  @override
  String get historyFieldAcquisitionDate => 'Data de aquisição';

  @override
  String get historyFieldWateringFrequency => 'Frequência de rega';

  @override
  String get historyAcquiredOn => 'Adquirida em';

  @override
  String historyCustomWatering(String days) {
    return 'Rega personalizada: $days';
  }

  @override
  String get historyUpdatedHeader => 'Informações atualizadas:';

  @override
  String get searchPlantsHint => 'Buscar plantas...';

  @override
  String get searchSpeciesHint => 'Buscar espécies...';

  @override
  String get searchSoilsHint => 'Buscar solos...';

  @override
  String get searchLocationsHint => 'Buscar localizações...';

  @override
  String get sortWateringNeeds => 'Necessidade de rega';

  @override
  String get sortNameAZ => 'Nome (A-Z)';

  @override
  String get sortNameZA => 'Nome (Z-A)';

  @override
  String get sortLastWatered => 'Última rega';

  @override
  String get sortDateAdded => 'Data de adição';

  @override
  String get sortPopularNameAZ => 'Nome Popular (A-Z)';

  @override
  String get sortPopularNameZA => 'Nome Popular (Z-A)';

  @override
  String get sortScientificNameAZ => 'Nome Científico (A-Z)';

  @override
  String get sortScientificNameZA => 'Nome Científico (Z-A)';

  @override
  String get sortNewestFirst => 'Mais recentes primeiro';

  @override
  String get sortOldestFirst => 'Mais antigos primeiro';

  @override
  String get sortByType => 'Por tipo';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String errorLoadingPlants(String error) {
    return 'Erro ao carregar plantas: $error';
  }

  @override
  String get noPlantsFound => 'Nenhuma planta encontrada';

  @override
  String get noPlantsRegistered => 'Nenhuma planta cadastrada';

  @override
  String get tapToAddFirstPlant =>
      'Toque em + para adicionar sua primeira planta.';

  @override
  String deletePlantsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deletar $count plantas?',
      one: 'Deletar $count planta?',
    );
    return '$_temp0';
  }

  @override
  String get deletePlantsBody =>
      'Todos os registros dessas plantas serão removidos.';

  @override
  String get deletePlantTitle => 'Deletar planta?';

  @override
  String get deletePlantBody =>
      'Todos os registros desta planta serão removidos.';

  @override
  String get cancelSelection => 'Cancelar seleção';

  @override
  String selectedCount(int count) {
    return '$count selecionada(s)';
  }

  @override
  String get deleteSelected => 'Excluir selecionadas';

  @override
  String get bulkEntryButton => 'Registro em massa';

  @override
  String get noPlantsAtLocation => 'Nenhuma planta nesta localização';

  @override
  String get plantsAtLocationHint =>
      'Defina esta localização em uma planta para vê-la aqui.';

  @override
  String get noPlantsOfSpecies => 'Nenhuma planta desta espécie';

  @override
  String get plantsOfSpeciesHint =>
      'Adicione uma planta desta espécie para vê-la aqui.';

  @override
  String get editPlant => 'Editar planta';

  @override
  String get newPlant => 'Nova planta';

  @override
  String get addPlant => 'Adicionar planta';

  @override
  String get sectionIdentification => 'Identificação';

  @override
  String get sectionCare => 'Cuidados';

  @override
  String get sectionDetails => 'Detalhes';

  @override
  String get sectionInformation => 'Informações';

  @override
  String get sectionCoordinates => 'Coordenadas';

  @override
  String get nicknameLabel => 'Apelido';

  @override
  String get nicknameHint => 'Ex: Samambaia da sala';

  @override
  String get nicknameRequired => 'Informe um apelido';

  @override
  String get speciesRequired => 'Selecione uma espécie';

  @override
  String get selectSpeciesFromList => 'Selecione uma espécie da lista';

  @override
  String get selectSoilType => 'Selecione um tipo de solo';

  @override
  String get newSoilType => 'Novo tipo de solo';

  @override
  String get newLocation => 'Nova localização';

  @override
  String get irrigationFrequencyLabel => 'Frequência de irrigação (dias)';

  @override
  String get irrigationFrequencyShort => 'Frequência de irrigação';

  @override
  String get irrigationFrequencyHelper =>
      'Se preenchido, o app enviará lembretes de rega.';

  @override
  String get recommendedSuffix => '(recomendado)';

  @override
  String get locationLabel => 'Localização';

  @override
  String get acquisitionDateLabel => 'Data de aquisição';

  @override
  String get acquiredOnLabel => 'Adquirida em';

  @override
  String get plantNotFound => 'Planta não encontrada';

  @override
  String get soilLabel => 'Solo';

  @override
  String get needsWater => 'Precisa de água!';

  @override
  String get wateringUpToDate => 'Irrigação em dia';

  @override
  String get lastWateringNotRecorded => 'Última rega não registrada';

  @override
  String daysOverdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias em atraso',
      one: '$days dia em atraso',
    );
    return '$_temp0';
  }

  @override
  String nextWateringInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Próxima irrigação em $days dias',
      one: 'Próxima irrigação em $days dia',
    );
    return '$_temp0';
  }

  @override
  String get wateredNow => 'Reguei agora';

  @override
  String get irrigationRecorded => 'Irrigação registrada!';

  @override
  String irrigationRecordError(String error) {
    return 'Erro ao registrar irrigação: $error';
  }

  @override
  String get entriesTitle => 'Registros';

  @override
  String get entryTypesTitle => 'Tipos de registro';

  @override
  String get filterTypes => 'Filtrar tipos';

  @override
  String get noEntriesFound => 'Nenhum registro encontrado';

  @override
  String get deleteEntryTitle => 'Deletar registro?';

  @override
  String get severityMild => 'Leve';

  @override
  String get severityModerate => 'Moderada';

  @override
  String get severitySevere => 'Severa';

  @override
  String get severityActive => 'Ativa';

  @override
  String get pestBadge => 'Praga';

  @override
  String get entryTypeIrrigation => 'Irrigação';

  @override
  String get entryTypeFertilizer => 'Fertilização';

  @override
  String get entryTypePruning => 'Poda';

  @override
  String get entryTypeObservation => 'Observação';

  @override
  String get entryTypeHeight => 'Altura';

  @override
  String get entryTypeChlorosis => 'Clorose';

  @override
  String get entryTypePest => 'Parasitas';

  @override
  String get entryTypeOther => 'Outro';

  @override
  String get entryTypeHistory => 'Histórico';

  @override
  String get newEntryTitle => 'Novo Registro';

  @override
  String newBulkEntryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Novo registro ($count plantas)',
      one: 'Novo registro ($count planta)',
    );
    return '$_temp0';
  }

  @override
  String get entryTypeCardTitle => 'Tipo de registro';

  @override
  String get notesTitle => 'Notas';

  @override
  String get noteHintIrrigation => 'Tinha algo na água? Alguma observação?';

  @override
  String get noteHintFertilizer => 'Frequência, método de aplicação...';

  @override
  String get noteHintPruning => 'Como a planta estava antes da poda?';

  @override
  String get noteHintObservation => 'Como a planta está hoje?';

  @override
  String get noteHintHeight => 'Alguma observação sobre o crescimento?';

  @override
  String get noteHintChlorosis => 'Quais folhas estão afetadas?';

  @override
  String get noteHintPest => 'Onde foi identificado? Algum tratamento?';

  @override
  String get noteHintDefault => 'Notas opcionais...';

  @override
  String get photoTitle => 'Foto';

  @override
  String get saveEntry => 'Salvar registro';

  @override
  String saveEntryForPlants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvar para $count plantas',
      one: 'Salvar para $count planta',
    );
    return '$_temp0';
  }

  @override
  String get pruningFormation => 'Formação';

  @override
  String get pruningCleaning => 'Limpeza';

  @override
  String get pruningRejuvenation => 'Rejuvenescimento';

  @override
  String get pruningHarvest => 'Colheita';

  @override
  String get pruningReasonHint => 'Motivo (opcional)';

  @override
  String get irrigationScarce => 'Escassa';

  @override
  String get irrigationScarceDesc => 'Solo levemente úmido';

  @override
  String get irrigationModerate => 'Moderada';

  @override
  String get irrigationModerateDesc => 'Rega normal, solo bem úmido';

  @override
  String get irrigationIntense => 'Intensa';

  @override
  String get irrigationIntenseDesc => 'Solo encharcado / longa duração';

  @override
  String get irrigationIntensityHint => 'Intensidade da rega (opcional)';

  @override
  String get fertilizerProductsHint => 'Produto(s) utilizado(s) — opcional';

  @override
  String get productLabel => 'Produto';

  @override
  String get productHint => 'Ex: Forth Crescimento';

  @override
  String get doseLabel => 'Dose';

  @override
  String get addProduct => 'Adicionar produto';

  @override
  String get healthScoreHint => 'Nota de saúde da planta (opcional)';

  @override
  String get healthCritical => 'Crítica';

  @override
  String get healthBad => 'Ruim';

  @override
  String get healthRegular => 'Regular';

  @override
  String get healthGood => 'Boa';

  @override
  String get healthExcellent => 'Ótima';

  @override
  String healthSummary(int score) {
    return 'Saúde $score/5';
  }

  @override
  String get heightSectionTitle => 'Altura da planta';

  @override
  String get heightCmLabel => 'Altura em cm';

  @override
  String get heightHint => 'Ex: 32,5';

  @override
  String get heightInvalid => 'Informe uma altura em cm válida';

  @override
  String get heightMeasureHint =>
      'Meça do nível do solo até a folha mais alta.';

  @override
  String get severitySelectHint => 'Selecione a gravidade *';

  @override
  String get chlorosisCured => 'Curada';

  @override
  String get chlorosisCuredDesc => 'Planta sem clorose ativa';

  @override
  String get chlorosisMildDesc => 'Poucas folhas amareladas';

  @override
  String get chlorosisModerateDesc => 'Várias folhas afetadas';

  @override
  String get chlorosisSevereDesc => 'Maioria das folhas afetadas';

  @override
  String get pestTypeLabel => 'Tipo de parasita';

  @override
  String get pestTypeHint => 'Ex: Cochonilha, Pulgão, Ácaro...';

  @override
  String get pestTypeRequired => 'Informe o tipo de parasita';

  @override
  String get pestSeverityHint => 'Gravidade da infestação *';

  @override
  String get pestEradicated => 'Erradicada';

  @override
  String get pestEradicatedDesc => 'Planta livre de parasitas';

  @override
  String get pestMildDesc => 'Poucos indivíduos / área pequena';

  @override
  String get pestModerateDesc => 'Várias áreas afetadas';

  @override
  String get pestSevereDesc => 'Infestação generalizada';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produtos',
      one: '$count produto',
    );
    return '$_temp0';
  }

  @override
  String get viewDiary => 'Diário';

  @override
  String get viewCharts => 'Gráficos';

  @override
  String get viewPhotos => 'Fotos';

  @override
  String get chartGrowthTitle => 'Crescimento';

  @override
  String get chartHealthTitle => 'Saúde geral';

  @override
  String get chartWateringTitle => 'Regularidade de rega';

  @override
  String get chartNeedTwoHeights =>
      'Registre a altura pelo menos duas vezes para ver a curva de crescimento.';

  @override
  String get chartNeedTwoHealth =>
      'Registre observações com nota de saúde para ver a tendência.';

  @override
  String get chartNeedTwoWaterings =>
      'Registre pelo menos duas regas para ver os intervalos.';

  @override
  String get chartsEmpty =>
      'Ainda não há dados para gráficos. Registre alturas, notas de saúde e regas no diário.';

  @override
  String get photosEmpty =>
      'Nenhuma foto nos registros ainda. Adicione fotos aos registros para montar a linha do tempo visual.';

  @override
  String chartWateringSummary(String avg, int ideal) {
    return 'Média: a cada $avg dias · Ideal: a cada $ideal dias';
  }

  @override
  String chartWateringAvgOnly(String avg) {
    return 'Média: a cada $avg dias';
  }

  @override
  String get chartIdealLabel => 'Ideal';

  @override
  String get editSpecies => 'Editar espécie';

  @override
  String get newSpecies => 'Nova espécie';

  @override
  String get addSpecies => 'Adicionar espécie';

  @override
  String get popularNameLabel => 'Nome popular';

  @override
  String get scientificNameLabel => 'Nome científico';

  @override
  String get scientificNameHint => 'Ex: Nephrolepis exaltata';

  @override
  String get defaultIrrigationFrequencyLabel =>
      'Frequência de irrigação padrão (dias)';

  @override
  String get recommendedSoils => 'Solos recomendados';

  @override
  String get speciesFieldLabel => 'Espécie';

  @override
  String get speciesSearchFieldHint => 'Busque na base oficial ou local...';

  @override
  String get speciesCustomHelper =>
      'Não encontrou? Toque em + para cadastrar sua própria espécie.';

  @override
  String get noSpeciesFound => 'Nenhuma espécie encontrada';

  @override
  String get noSpeciesRegistered => 'Nenhuma espécie cadastrada';

  @override
  String get tapToAddSpecies => 'Toque em + para adicionar uma nova espécie.';

  @override
  String get deleteSpeciesTitle => 'Deletar espécie?';

  @override
  String get deleteSpeciesBody =>
      'Plantas vinculadas a esta espécie não serão afetadas.';

  @override
  String get floraBrasilBanner =>
      'Usando dados oficiais da Flora e Funga do Brasil (JBRJ).';

  @override
  String totalSpeciesAvailable(String count) {
    return 'Total de espécies disponíveis: $count';
  }

  @override
  String lastUpdate(String date) {
    return 'Última atualização: $date';
  }

  @override
  String get downloadUpdatedDataset => 'Baixar versão atualizada (JBRJ)';

  @override
  String get datasetDownloadStarted =>
      'Iniciando download do dataset oficial...';

  @override
  String get datasetUpdated => 'Dataset atualizado com sucesso!';

  @override
  String datasetUpdateError(String error) {
    return 'Erro ao atualizar: $error';
  }

  @override
  String get soilSandy => 'Arenoso';

  @override
  String get soilClay => 'Argiloso';

  @override
  String get soilLoamy => 'Franco';

  @override
  String get soilPeaty => 'Turfoso';

  @override
  String get soilChalky => 'Calcário';

  @override
  String get soilSilty => 'Siltoso';

  @override
  String get soilLatosol => 'Latossolo';

  @override
  String get soilArgisol => 'Argissolo';

  @override
  String get soilTerraRoxa => 'Terra Roxa';

  @override
  String get soilMassape => 'Massapê';

  @override
  String get soilAlluvial => 'Aluvial/Várzea';

  @override
  String get soilTerraVegetal => 'Terra Vegetal';

  @override
  String get soilPottingMix => 'Substrato Pronto';

  @override
  String get soilWormCastings => 'Húmus de Minhoca';

  @override
  String get soilSucculentMix => 'Substrato p/ Suculentas';

  @override
  String get soilCoconutFiber => 'Fibra de Coco';

  @override
  String get soilManure => 'Esterco Curtido';

  @override
  String get soilSandyDesc => 'Alta drenagem, baixa retenção de nutrientes.';

  @override
  String get soilClayDesc => 'Alta retenção de água, tende a compactar.';

  @override
  String get soilLoamyDesc => 'Equilibrado entre areia, silte e argila.';

  @override
  String get soilPeatyDesc => 'Rico em matéria orgânica, retém muita umidade.';

  @override
  String get soilChalkyDesc => 'Pedregoso e alcalino, boa drenagem.';

  @override
  String get soilSiltyDesc => 'Retém bem a umidade, fértil e macio.';

  @override
  String get soilLatosolDesc =>
      'Rico em ferro e alumínio. Muito poroso e bem drenado.';

  @override
  String get soilArgisolDesc =>
      'Acúmulo de argila em profundidade. Risco de erosão.';

  @override
  String get soilTerraRoxaDesc =>
      'Origem vulcânica. Extrema fertilidade e cor avermelhada.';

  @override
  String get soilMassapeDesc =>
      'Escuro, muito argiloso e fértil. Típico do NE.';

  @override
  String get soilAlluvialDesc =>
      'Sedimentos de rios. Naturalmente fértil e jovem.';

  @override
  String get soilTerraVegetalDesc =>
      'Terra mineral misturada com restos vegetais decompostos.';

  @override
  String get soilPottingMixDesc =>
      'Mix balanceado de turfa, casca de pinus e perlita.';

  @override
  String get soilWormCastingsDesc =>
      'Rico em NPK e microrganismos. Ótimo fertilizante.';

  @override
  String get soilSucculentMixDesc =>
      'Alta drenagem. 50% orgânico e 50% areia ou perlita.';

  @override
  String get soilCoconutFiberDesc =>
      'Melhora a aeração e mantém umidade controlada.';

  @override
  String get soilManureDesc =>
      'Adubo orgânico rico. Deve ser usado sempre decomposto.';

  @override
  String get editSoil => 'Editar solo';

  @override
  String get newSoil => 'Novo Solo';

  @override
  String get createSoil => 'Criar solo';

  @override
  String get selectSoilTitle => 'Selecionar Solo';

  @override
  String get soilTypeLabel => 'Tipo de solo';

  @override
  String get soilNameLabel => 'Nome do Solo';

  @override
  String get soilNameHint => 'Ex: Solo Orgânico Premium';

  @override
  String get compositionLabel => 'Composição (opcional)';

  @override
  String get compositionHint => 'Ex: 40% húmus, 30% perlita, 30% fibra de coco';

  @override
  String get compositionHelper => 'Uma linha descrevendo a mistura.';

  @override
  String get imageSourceLabel => 'Fonte da Imagem (opcional)';

  @override
  String get imageSourceHint => 'Ex: https://exemplo.com/foto';

  @override
  String imageSource(String source) {
    return 'Fonte: $source';
  }

  @override
  String get tapToChangeImage => 'Toque para alterar a imagem';

  @override
  String get noSoilsFound => 'Nenhum solo encontrado';

  @override
  String get noSoilsRegistered => 'Nenhum tipo de solo cadastrado';

  @override
  String get tapToAddSoil => 'Toque em + para adicionar um tipo de solo.';

  @override
  String get deleteSoilTitle => 'Deletar solo?';

  @override
  String get deleteSoilBody =>
      'Plantas e espécies vinculadas a este solo não serão deletadas, mas a referência ao solo pode ser perdida.';

  @override
  String get editLocation => 'Editar localização';

  @override
  String get addLocation => 'Adicionar localização';

  @override
  String get locationNameHint => 'Ex: Sala de estar, Varanda, Quarto';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String outOfRange(String min, String max) {
    return 'Fora do intervalo [$min, $max]';
  }

  @override
  String get gettingLocation => 'Obtendo localização...';

  @override
  String get useCurrentLocation => 'Usar localização atual';

  @override
  String get noLocationsFound => 'Nenhuma localização encontrada';

  @override
  String get noLocationsRegistered => 'Nenhuma localização cadastrada';

  @override
  String get tapToAddLocation => 'Toque em + para adicionar uma localização.';

  @override
  String get deleteLocationTitle => 'Deletar localização?';

  @override
  String get deleteLocationBody =>
      'Plantas vinculadas a esta localização não serão deletadas, mas ficarão sem localização.';

  @override
  String get settingsGeneral => 'Geral';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsSync => 'Sincronização';

  @override
  String get settingsData => 'Dados';

  @override
  String get wateringNotifications => 'Notificações de Rega';

  @override
  String get wateringNotificationsSubtitle =>
      'Habilitar ou desabilitar lembretes';

  @override
  String get notificationTime => 'Horário dos lembretes';

  @override
  String get notificationTimeSubtitle =>
      'Quando os lembretes de rega são exibidos';

  @override
  String get transparencyAndBlur => 'Transparência e Blur';

  @override
  String get transparencyAndBlurSubtitle =>
      'Efeitos visuais em cartões e menus';

  @override
  String get darkMode => 'Modo Noturno';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get aboutApp => 'Sobre o Aplicativo';

  @override
  String get noRemoteWorkspaces =>
      'Nenhum workspace remoto ainda. Adicione um para sincronizar estes dados com um servidor.';

  @override
  String get addRemoteWorkspace => 'Adicionar workspace remoto';

  @override
  String reconnectWorkspace(String name) {
    return 'Reconectar \"$name\"';
  }

  @override
  String get disconnectBody =>
      'Os dados deste workspace continuam neste dispositivo. Para sincronizar novamente, entre com sua conta.';

  @override
  String deleteWorkspaceTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get deleteWorkspaceBody =>
      'Os dados deste workspace serão apagados deste dispositivo. Isso não afeta a conta nem os dados no servidor.';

  @override
  String get adminPermissionLost =>
      'Você não tem mais permissão de administrador.';

  @override
  String get renameWorkspace => 'Renomear workspace';

  @override
  String get localChip => 'Local';

  @override
  String get localNoSync => 'Local — não sincroniza';

  @override
  String get dataOnlyOnDevice => 'Dados só neste dispositivo';

  @override
  String get serverAdministration => 'Administração do servidor';

  @override
  String get serverAddressTitle => 'Endereço do servidor';

  @override
  String get createFirstAccountTitle => 'Criar primeira conta do servidor';

  @override
  String get migrateLocalDataTitle => 'Migrar dados locais?';

  @override
  String get migrateLocalDataBody =>
      'Encontramos dados salvos apenas neste dispositivo (workspace local). Deseja enviá-los agora para este servidor?';

  @override
  String get serverUrlLabel => 'URL do servidor';

  @override
  String get mustStartWithHttp => 'Deve começar com http:// ou https://';

  @override
  String get firstAccountInfo =>
      'Este servidor ainda não tem nenhuma conta. Crie a conta principal abaixo — ela será usada para acessá-lo daqui em diante.';

  @override
  String get workspaceNameLabel => 'Nome deste workspace';

  @override
  String get workspaceNameHint => 'Ex: Estufa de casa';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get confirmPasswordLabel => 'Confirmar senha';

  @override
  String get passwordMinChars => 'Mínimo de 6 caracteres';

  @override
  String get passwordsDontMatch => 'As senhas não coincidem';

  @override
  String get unexpectedConnectError => 'Erro inesperado ao conectar.';

  @override
  String get unexpectedLoginError => 'Erro inesperado ao entrar.';

  @override
  String get unexpectedRegisterError => 'Erro inesperado ao criar conta.';

  @override
  String get unexpectedMigrateError => 'Erro inesperado ao migrar os dados.';

  @override
  String get promoteToAdminTitle => 'Promover a admin?';

  @override
  String get demoteToMemberTitle => 'Rebaixar para membro?';

  @override
  String promoteToAdminBody(String email) {
    return '$email passará a ter acesso total de administração do servidor.';
  }

  @override
  String demoteToMemberBody(String email) {
    return '$email perderá o acesso de administração do servidor.';
  }

  @override
  String get promote => 'Promover';

  @override
  String get demote => 'Rebaixar';

  @override
  String get promoteToAdmin => 'Promover a admin';

  @override
  String get demoteToMember => 'Rebaixar para membro';

  @override
  String get disableAccountTitle => 'Desativar conta?';

  @override
  String get enableAccountTitle => 'Reativar conta?';

  @override
  String disableAccountBody(String email) {
    return '$email não conseguirá mais entrar. Os dados são mantidos.';
  }

  @override
  String enableAccountBody(String email) {
    return '$email poderá entrar novamente.';
  }

  @override
  String get disable => 'Desativar';

  @override
  String get enable => 'Reativar';

  @override
  String get disableAccount => 'Desativar conta';

  @override
  String get enableAccount => 'Reativar conta';

  @override
  String get addUser => 'Adicionar usuário';

  @override
  String errorLoadingUsers(String error) {
    return 'Erro ao carregar usuários: $error';
  }

  @override
  String errorLoadingStatus(String error) {
    return 'Erro ao carregar status: $error';
  }

  @override
  String errorLoadingPermissions(String error) {
    return 'Erro ao carregar permissões: $error';
  }

  @override
  String get serverCardTitle => 'Servidor';

  @override
  String serverUptime(String uptime) {
    return 'Uptime: $uptime';
  }

  @override
  String serverVersion(String version) {
    return 'Versão: $version';
  }

  @override
  String serverUsers(String count) {
    return 'Usuários: $count';
  }

  @override
  String get memberPermissions => 'Permissões de membros';

  @override
  String get memberExportSubtitle => 'Membros podem exportar os próprios dados';

  @override
  String get memberImportSubtitle =>
      'Membros podem importar dados de um backup';

  @override
  String get youChip => 'Você';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleMember => 'Membro';

  @override
  String get accountDisabled => 'Desativado';

  @override
  String get exportData => 'Exportar dados';

  @override
  String get importData => 'Importar dados';

  @override
  String get exportDataSubtitle => 'Gera um arquivo .zip com os dados e fotos';

  @override
  String get importDataSubtitle =>
      'Mescla um backup exportado com os dados atuais';

  @override
  String get checkingPermission => 'Verificando permissão...';

  @override
  String get permissionCheckFailed =>
      'Não foi possível verificar a permissão com o servidor.';

  @override
  String get connectToTransfer =>
      'Conecte-se ao servidor para exportar ou importar.';

  @override
  String get disabledByAdmin => 'Desativado pelo administrador do servidor.';

  @override
  String dataExportedTo(String path) {
    return 'Dados exportados para $path';
  }

  @override
  String exportError(String error) {
    return 'Erro ao exportar: $error';
  }

  @override
  String get importDataTitle => 'Importar dados?';

  @override
  String importDataBody(String fileName) {
    return 'Os dados de \"$fileName\" serão mesclados aos dados deste workspace. Itens editados mais recentemente no aplicativo são mantidos.';
  }

  @override
  String get importAction => 'Importar';

  @override
  String importDone(int applied) {
    String _temp0 = intl.Intl.pluralLogic(
      applied,
      locale: localeName,
      other: 'Importação concluída: $applied itens aplicados.',
      one: 'Importação concluída: $applied item aplicado.',
    );
    return '$_temp0';
  }

  @override
  String importDoneWithSkipped(int applied, int skipped) {
    return 'Importação concluída: $applied item(ns) aplicados, $skipped ignorados por serem mais antigos.';
  }

  @override
  String get backupCorrupt => 'Arquivo de backup inválido.';

  @override
  String get backupUnrecognized =>
      'Arquivo não reconhecido: esperado um .zip ou .json de backup.';

  @override
  String get backupNotPolypodium =>
      'Este arquivo não é um backup do Polypodium.';

  @override
  String get backupNewerVersion =>
      'Backup gerado por uma versão mais nova do aplicativo. Atualize o Polypodium para importá-lo.';
}
