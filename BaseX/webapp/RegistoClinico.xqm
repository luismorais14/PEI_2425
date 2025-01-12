module namespace page = 'http://basex.org/examples/web-page';
declare namespace xs = 'http://www.w3.org/2001/XMLSchema';
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare namespace schemaLocation = "http://www.MedSync.pt/RegistoClinico RegistoClinico.xsd";

import module namespace http = 'http://expath.org/ns/http-client';
import module namespace json = 'http://basex.org/modules/json';

(: Função do relatório dos registros clínicos :)

declare 
  %rest:path("getRegistoClinico")
  %rest:query-param("year", "{$year}")
  %rest:query-param("month", "{$month}")
  %rest:GET
  function page:getRegistoClinico($year as xs:integer, $month as xs:integer) {
    let $url := concat('http://localhost:3000/RegistoClinico?year=', $year, '&amp;month=', $month)
    let $response := http:send-request(<http:request method="get" href="{$url}"/>)
    let $json := $response[2]/*
    
    return
      <RelatorioHospital xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                          xsi:noNamespaceSchemaLocation="RegistoClinico.xsd"
                          xsi:schemaLocation="http://www.MedSync.pt/RegistoClinico RegistoClinico.xsd">
        
        <Hospital>
          <CodHospital>H123</CodHospital>
          <NomeHospital>Hospital Felgueiras</NomeHospital>
          <MoradaHospital>Rua da ESTGf, 11</MoradaHospital>
          <MesRelatorio>{xs:string($month)}</MesRelatorio>
          <AnoFiscalRelatorio>{xs:string($year)}</AnoFiscalRelatorio>
        </Hospital>

        <ListaPacientes>
          {
            for $paciente in $json/listaPacientes/*
            return 
              <Paciente>
                <NomeCompleto>{$paciente/Nome__Completo/text()}</NomeCompleto>
                <DataNascimento>{$paciente/Data__Nascimento__Paciente/text()}</DataNascimento>
                <Genero>{$paciente/Genero/text()}</Genero>
                <ID>{xs:string($paciente/ID__Paciente)}</ID>
                <Contacto>
                  <Telefone>{$paciente/Contactos/Telefone/text()}</Telefone>
                  <Email>{$paciente/Contactos/Email/text()}</Email>
                </Contacto>
                <TipoPaciente>{$paciente/Tipo__Paciente/text()}</TipoPaciente>
              </Paciente>
          }
        </ListaPacientes>

        <RegistosClinicos>
          {
            for $registo in $json/registoClinico/*
            return 
              <Registo>
                <CodAtendimento>{$registo/ID__Atendimento/text()}</CodAtendimento>
                <Data>{$registo/Data__Atendimento/text()}</Data>
                <Especialidade>{$registo/Especialidade/text()}</Especialidade>
                
                {
                  if ($registo/Diagnosticos) then 
                    <Diagnosticos>
                      {
                        for $diag in $registo/Diagnosticos/*
                        return 
                          <Diagnostico>
                            <TipoDiagnostico>{$diag/Tipo__Diagnostico/text()}</TipoDiagnostico>
                            <CodigoCID10>{$diag/Codigo__CID10/text()}</CodigoCID10>
                            <DescricaoDiagnostico>{$diag/Descricao__Diagnostico/text()}</DescricaoDiagnostico>
                          </Diagnostico>
                      }
                    </Diagnosticos>
                  else ()
                }
                
                <Tratamentos>
                  {
                    for $tratamento in $registo/Tratamentos/*
                    return 
                      <Tratamento>
                        <ID>{xs:integer($tratamento/ID__Tratamento/text())}</ID>
                        <IdRegistoClinico>{xs:integer($tratamento/ID__Registro__Clinico/text())}</IdRegistoClinico>
                        <Tipo>{$tratamento/Tipo__Tratamento/text()}</Tipo>
                        <Realizado>{$tratamento/Realizado/text()}</Realizado>
                      </Tratamento>
                  }
                </Tratamentos>
                
                <ID_Profissional>{$registo/ID__Profissional/text()}</ID_Profissional>
              </Registo>
          }
        </RegistosClinicos>

        <ResumoMensal>
    
<PacientesAtendidos>
    <PorGenero>
        {
            for $genero in $json/resumoMensalRegistoClinico/numeroPacientesAtendidosGenero/*
            return (
                <Genero>{$genero/Genero/text()}</Genero>,
                <Total>{$genero/Total/text()}</Total>
            )
        }
    </PorGenero>
    <PorFaixaEtaria>
        {
            for $faixa in $json/resumoMensalRegistoClinico/numeroPacientesFaixaEtaria/*
            return (
                <FaixaEtaria>{$faixa/Faixa__Etaria/text()}</FaixaEtaria>,
                <Total>{$faixa/Total/text()}</Total>
            )
        }
    </PorFaixaEtaria>
</PacientesAtendidos>
          <CasosPorEspecialidade>
            {
              for $caso in $json/resumoMensalRegistoClinico/casosPorEspecialidade/*
              return 
                  (
                    <Especialidade>{$caso/Especialidade/text()}</Especialidade>,
                  <Total>{$caso/Total/text()}</Total>
                )
            }
          </CasosPorEspecialidade>

          <TratamentosRealizados>
            {
              let $tratamentos := $json/resumoMensalRegistoClinico/numeroTratamentosRealizados/*
              return 
                if ($tratamentos) then 
                  $tratamentos/totalTratamentos/text()
                else 
                  "0"
            }
          </TratamentosRealizados>

          <NumeroCondicoesCronicas>
            {
              let $condicoes := $json/resumoMensalRegistoClinico/numeroCondicoesCronicas/*
              return 
                if ($condicoes) then 
                  $condicoes/Total__Condicoes__Cronicos/text()
                else 
                  "0"
            }
          </NumeroCondicoesCronicas>
        </ResumoMensal>

      </RelatorioHospital>
  };

(: Função do relatório das transferências :)

declare 
  %rest:path("getTransferencias")
  %rest:query-param("year", "{$year}")
  %rest:query-param("month", "{$month}")
  %rest:GET
  function page:getTransferencias($year as xs:integer, $month as xs:integer) {
    let $url := concat('http://localhost:3000/Transferencias?year=', $year, '&amp;month=', $month)
    let $response := http:send-request(<http:request method="get" href="{$url}"/>)
    let $json := $response[2]/*
    
    return 
      <Relatorio xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xsi:noNamespaceSchemaLocation="Transferencias.xsd"
                   xsi:schemaLocation="http://www.MedSync.pt/Transferencias Transferencias.xsd">
        
        {
          for $transferencia in $json/registoTransferencias/*
          return 
            <HospitalDestino>
              <NomeHospital>{$transferencia/Hospital__Destino/text()}</NomeHospital>
              <RegistosTransferencias>
                <CodigoPaciente>{$transferencia/Paciente/ID__Paciente/text()}</CodigoPaciente>
                <DataTransferencia>{$transferencia/Data__Transferencia/text()}</DataTransferencia>
                <Motivo>{$transferencia/Motivo/text()}</Motivo>
                <Diagnosticos>
                  {
                    for $diagnostico in subsequence($transferencia/Diagnosticos/*, 1, 3) 
                    return 
                      <Diagnostico>
                        <CodigoCID10>{$diagnostico/Codigo__CID10/text()}</CodigoCID10>
                        <Descricao>{$diagnostico/Descricao__Diagnostico/text()}</Descricao>
                        <Tipo>{$diagnostico/Tipo__Diagnostico/text()}</Tipo>
                      </Diagnostico>
                  }
                </Diagnosticos>
                <Tratamentos>
                  {
                    for $tratamento in subsequence($transferencia/Tratamentos/*, 1, 3) 
                    return 
                      <Tratamento>
                        <ID>{$tratamento/ID__Tratamento/text()}</ID>
                        <IdRegistoClinico>{$tratamento/ID__Registro__Clinico/text()}</IdRegistoClinico>
                        <Tipo>{$tratamento/Tipo__Tratamento/text()}</Tipo>
                        <Realizado>{$tratamento/Realizado/text()}</Realizado>
                      </Tratamento>
                  }
                </Tratamentos>
              </RegistosTransferencias>
            </HospitalDestino>
        }
        
        <ResumoMensal>
          <NumeroTotalDeTransferenciasPorMotivo>
            {
              for $resumoMotivo in $json/resumoMensalTransferencias/NumeroTotalTransferenciasPorMotivo/*
              return 
                <MotivoDetalhes>
                  <Motivo>{$resumoMotivo/Motivo/text()}</Motivo>
                  <Total>{xs:int($resumoMotivo/Numero__Total/text())}</Total>
                </MotivoDetalhes>
            }
          </NumeroTotalDeTransferenciasPorMotivo>

          <NumeroTotalDeTransferenciasPorTipo>
            {
              for $resumoTipo in $json/resumoMensalTransferencias/NumeroTotalTransferenciasPorTipo/*
              return 
                <TipoDetalhes>
                  <Tipo>{$resumoTipo/Tipo/text()}</Tipo>
                  <Total>{xs:int($resumoTipo/Numero__Total/text())}</Total>
                </TipoDetalhes>
            }
          </NumeroTotalDeTransferenciasPorTipo>

          <NumeroTotalDeTransferenciasPorHospital>
            {
              for $resumoHospital in $json/resumoMensalTransferencias/NumeroTotalTransferenciasPorHospital/*
              return 
                <HospitalDetalhes>
                  <NomeHospital>{$resumoHospital/NomeHospital/text()}</NomeHospital>
                  <Total>{xs:int($resumoHospital/Numero__Total/text())}</Total>
                </HospitalDetalhes>
            }
          </NumeroTotalDeTransferenciasPorHospital>
        </ResumoMensal>
      </Relatorio>
  };

