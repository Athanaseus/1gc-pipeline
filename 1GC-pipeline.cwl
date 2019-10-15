#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
doc: simple_simulation
requirements:
- class: MultipleInputFeatureRequirement
inputs:
  getms_mstar: File
  obsinfo_listfile: string
  setmodel_standard:
    type:
      type: enum
      symbols:
      - Perley-Butler 2010
      - Perley-Butler 2013
      - Baars
      - Perley 90
      - Perley-Taylor 95
      - Perley-Taylor 99
      - Scaife-Heald 2012
      - Stevens-Reynolds 2016
      - Butler-JPL-Horizons 2010
      - Butler-JPL-Horizons 2012
      - manual
      - fluxscale
      name: standarddfdf9022-9e53-4fb7-b057-f860e742dd70
  setmodel_field: string
  setmodel_usescratch: boolean
  setmodel_scalebychan: boolean
  delaycal_field: string
  delaycal_refant: string
  delaycal_gaintype:
    type:
      type: enum
      symbols:
      - G
      - T
      - GSPLINE
      - K
      - KCROSS
      name: gaintypecb87b541-1221-49fd-90bd-9b322a8ec85d
  delaycal_solint: string
  delaycal_uvrange: string
  delaycal_caltable: string
  bpcal_refant: string
  bpcal_bandtype:
    type:
      type: enum
      symbols:
      - B
      - BPOLY
      name: bandtype29d7295e-3f38-45d9-982a-d0aec249c1a8
  bpcal_combine: string
  bpcal_solint: string
  bpcal_caltable: string
  gaincal_refant: string
  gaincal_gaintype:
    type:
      type: enum
      symbols:
      - G
      - T
      - GSPLINE
      - K
      - KCROSS
      name: gaintype8afeba71-2327-4daf-a915-e5f22f8bf961
  gaincal_combine: string
  gaincal_solint: string
  gaincal_caltable: string
  gaincal_calmode:
    type:
      type: enum
      symbols:
      - ap
      - p
      - a
      name: calmode7371d187-4bbb-447f-963a-eb347eb32880
  applycal_field: string
  applycal_gainfield:
    type:
      type: array
      items: string
  applycal_interp:
    type:
      type: array
      items: string
  applycal_calwt:
    type:
      type: array
      items: boolean
  applycal_parang: boolean
  applycal_applymode:
    type:
      type: enum
      symbols:
      - calflag
      - calflagstrict
      - trial
      - flagonly
      - flagonlystrict
      - calonly
      name: applymode7d24acb3-fe24-401b-a9de-9f8ab8c437aa
  plot_delays_field: int
  plot_delays_gaintype:
    type:
      type: enum
      symbols:
      - B
      - F
      - G
      - K
      name: gaintype8ad16829-637a-4c44-84d9-e85b20c7a481
  plot_delays_htmlname: string
  plot_bandpass_field: int
  plot_bandpass_gaintype:
    type:
      type: enum
      symbols:
      - B
      - F
      - G
      - K
      name: gaintype9bb1eeb3-7082-4664-81ca-2f662f774a44
  plot_bandpass_htmlname: string
  plot_gains_field: int
  plot_gains_gaintype:
    type:
      type: enum
      symbols:
      - B
      - F
      - G
      - K
      name: gaintypeac3db016-266c-42e0-9287-8b10c91f3dd4
  plot_gains_htmlname: string
  makeimage_name: string
  makeimage_channels-out: int
  makeimage_weight: string
  makeimage_field: int
  makeimage_padding: float
  makeimage_mgain: float
  makeimage_scale: string
  makeimage_niter: int
  makeimage_auto-threshold: float
  makeimage_size:
    type:
      type: array
      items: int
outputs:
  makeimage_0:
    outputSource: wsclean/msname_out
    type: Directory
  makeimage_1:
    outputSource: wsclean/name_out
    type:
      type: array
      items: File
  plot_delays_0:
    outputSource: ragavi/htmlout
    type: File
  plot_delays_1:
    outputSource: ragavi/plotout
    type:
    - 'null'
    - File
  plot_bandpass_0:
    outputSource: ragavi-1/htmlout
    type: File
  plot_bandpass_1:
    outputSource: ragavi-1/plotout
    type:
    - 'null'
    - File
  plot_gains_0:
    outputSource: ragavi-2/htmlout
    type: File
  plot_gains_1:
    outputSource: ragavi-2/plotout
    type:
    - 'null'
    - File
steps:
  untar:
    run: cwlfiles/untar.cwl
    in:
      mstar: getms_mstar
    out:
    - ms
  casa_listobs:
    run: cwlfiles/casa_listobs.cwl
    in:
      vis: untar/ms
      listfile: obsinfo_listfile
    out:
    - listfile_out
    - vis_out
  casa_setjy:
    run: cwlfiles/casa_setjy.cwl
    in:
      standard: setmodel_standard
      vis: casa_listobs/vis_out
      field: setmodel_field
      scalebychan: setmodel_scalebychan
      usescratch: setmodel_usescratch
    out:
    - vis_out
  casa_gaincal:
    run: cwlfiles/casa_gaincal.cwl
    in:
      caltable: delaycal_caltable
      vis: casa_setjy/vis_out
      field: delaycal_field
      gaintype: delaycal_gaintype
      refant: delaycal_refant
      solint: delaycal_solint
      uvrange: delaycal_uvrange
    out:
    - caltable_append_out
    - caltable_out
    - vis_out
  casa_bandpass:
    run: cwlfiles/casa_bandpass.cwl
    in:
      solint: bpcal_solint
      vis: casa_gaincal/vis_out
      bandtype: bpcal_bandtype
      caltable: bpcal_caltable
      combine: bpcal_combine
      gaintable: casa_gaincal/caltable_out
      refant: bpcal_refant
    out:
    - caltable_append_out
    - caltable_out
    - vis_out
  casa_gaincal-1:
    run: cwlfiles/casa_gaincal.cwl
    in:
      caltable: gaincal_caltable
      vis: casa_bandpass/vis_out
      calmode: gaincal_calmode
      combine: gaincal_combine
      gaintable_list:
      - &id001 casa_gaincal/caltable_out
      - &id002 casa_bandpass/caltable_out
      gaintype: gaincal_gaintype
      refant: gaincal_refant
      solint: gaincal_solint
    out:
    - caltable_append_out
    - caltable_out
    - vis_out
  casa_applycal:
    run: cwlfiles/casa_applycal.cwl
    in:
      applymode: applycal_applymode
      vis: casa_gaincal-1/vis_out
      calwt: applycal_calwt
      field: applycal_field
      gainfield: applycal_gainfield
      gaintable_list:
      - *id001
      - *id002
      - casa_gaincal-1/caltable_out
      interp: applycal_interp
      parang: applycal_parang
    out:
    - vis_out
  ragavi:
    run: cwlfiles/ragavi.cwl
    in:
      field: plot_delays_field
      gaintype: plot_delays_gaintype
      htmlname: plot_delays_htmlname
      table: casa_gaincal/caltable_out
    out:
    - htmlout
    - plotout
  ragavi-1:
    run: cwlfiles/ragavi.cwl
    in:
      field: plot_bandpass_field
      gaintype: plot_bandpass_gaintype
      htmlname: plot_bandpass_htmlname
      table: casa_bandpass/caltable_out
    out:
    - htmlout
    - plotout
  ragavi-2:
    run: cwlfiles/ragavi.cwl
    in:
      field: plot_gains_field
      gaintype: plot_gains_gaintype
      htmlname: plot_gains_htmlname
      table: casa_gaincal-1/caltable_out
    out:
    - htmlout
    - plotout
  wsclean:
    run: cwlfiles/wsclean.cwl
    in:
      msname: casa_applycal/vis_out
      name: makeimage_name
      field: makeimage_field
      mgain: makeimage_mgain
      niter: makeimage_niter
      padding: makeimage_padding
      scale: makeimage_scale
      size: makeimage_size
      weight: makeimage_weight
    out:
    - msname_out
    - name_out
