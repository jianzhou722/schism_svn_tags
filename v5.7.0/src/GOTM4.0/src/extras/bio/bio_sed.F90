!$Id: bio_sed.F90,v 1.9 2007-04-18 07:35:26 kbk Exp $
#include"cppdefs.h"
!-----------------------------------------------------------------------
!BOP
!
! !MODULE: bio_sed --- simple suspended matter model \label{sec:biosed}
!
! !INTERFACE:
   module bio_sed
!
! !DESCRIPTION:
!  This is a simple suspended matter model with one non-dimensional
!  state variable called {\tt conc}. The suspended matter is subject
!  to a constant settling velocity, has no surface fluxes of suspended matter,
!  but the suspended matter may be taken out at the bed, if the mussel
!  module of GOTM is activated. No right-hand side process terms are 
!  involved here.
!
! !USES:
!  default: all is private.
   use bio_var
   private
!
! !PUBLIC MEMBER FUNCTIONS:
   public init_bio_sed, init_var_sed, var_info_sed, &
          do_bio_sed, end_bio_sed
!
! !REVISION HISTORY:!
!  Original author(s): Hans Burchard & Karsten Bolding
!
!  $Log: bio_sed.F90,v $
!  Revision 1.9  2007-04-18 07:35:26  kbk
!  to avoid F95 warning
!
!  Revision 1.8  2007-01-06 11:49:15  kbk
!  namelist file extension changed .inp --> .nml
!
!  Revision 1.7  2006-10-26 13:12:46  kbk
!  updated bio models to new ode_solver
!
!  Revision 1.6  2005-12-02 20:57:27  hb
!  Documentation updated and some bugs fixed
!
!  Revision 1.5  2005-11-17 09:58:18  hb
!  explicit argument for positive definite variables in diff_center()
!
!  Revision 1.4  2005/09/19 21:03:31  hb
!  pp and dd properly set to zero
!
!  Revision 1.3  2004/08/02 08:34:36  hb
!  updated init routines to reflect new internal bio interface
!
!  Revision 1.2  2004/07/30 09:22:20  hb
!  use bio_var in specific bio models - simpliefied internal interface
!
!  Revision 1.1  2003/10/28 10:22:45  hb
!  added support for sedimentation only 1 compartment bio model
!
!
! !LOCAL VARIABLES:
!  from a namelist
   REALTYPE                  :: C_initial=4.5
   REALTYPE                  :: w_C=-5.787037e-05
!EOP
!-----------------------------------------------------------------------

   contains

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Initialise the bio module
!
! !INTERFACE:
   subroutine init_bio_sed(namlst,fname,unit)
!
! !DESCRIPTION:
!  Here, the bio namelist {\tt bio\_sed.nml} (mainly including
!  settling velocity and initial value) is read
!  and the settling velocity is converted to SI units.
!
! !USES:
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer,          intent(in)   :: namlst
   character(len=*), intent(in)   :: fname
   integer,          intent(in)   :: unit
!
! !REVISION HISTORY:
!  Original author(s): Hans Burchard & Karsten Bolding
!
! !LOCAL VARIABLES:
   namelist /bio_sed_nml/ numc,C_initial,w_C
!EOP
!-----------------------------------------------------------------------
!BOC
   LEVEL2 'init_bio_sed'

   open(namlst,file=fname,action='read',status='old',err=98)
   read(namlst,nml=bio_sed_nml,err=99)
   close(namlst)

   LEVEL3 'Sedimentation bio module initialised ...'

   numcc=numc

   w_C = w_C/86400.

   return

98 LEVEL2 'I could not open bio_sed.nml'
   LEVEL2 'If thats not what you want you have to supply bio_sed.nml'
   LEVEL2 'See the bio example on www.gotm.net for a working bio_sed.nml'
   return
99 FATAL 'I could not read bio_sed.nml'
   stop 'init_bio_sed'
   end subroutine init_bio_sed
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Initialise the concentration variables
!
! !INTERFACE:
   subroutine init_var_sed(nlev)
!
! !DESCRIPTION:
!  Here, the initial concentrations are set and the settling velocity is
!  transferred to all vertical levels.
!
! !USES:
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: nlev
!
! !REVISION HISTORY:
!  Original author(s): Hans Burchard & Karsten Bolding

!EOP
!-----------------------------------------------------------------------
!BOC
   cc(1,:)=C_initial

   ws(1,:) = w_C

   posconc(1) = 1

#if 0
   mussels_inhale(1) = .true.
#endif

   LEVEL3 'Sedimentation variables initialised ...'

   return

   end subroutine init_var_sed
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Providing info on variable names
!
! !INTERFACE:
   subroutine var_info_sed()
!
! !DESCRIPTION:
!  This subroutine provides information about the variable names as they
!  will be used when storing data in NetCDF files.
!
! !USES:
   IMPLICIT NONE
!
! !REVISION HISTORY:
!  Original author(s): Hans Burchard & Karsten Bolding
!
! !LOCAL VARIABLES:
!EOP
!-----------------------------------------------------------------------
!BOC
   var_names(1) = 'conc'
   var_units(1) = 'fractions'
   var_long(1)  = 'concentration'

   return
   end subroutine var_info_sed
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Right hand sides of geobiochemical model
!
! !INTERFACE:
   subroutine do_bio_sed(first,numc,nlev,cc,pp,dd)
!
! !DESCRIPTION:
! This routine sets the sinks and sources of this simple suspended
! matter module to zero.
!
! !USES:
   IMPLICIT NONE

! !INPUT PARAMETERS:
   logical, intent(in)                  :: first
   integer, intent(in)                  :: numc,nlev
   REALTYPE, intent(in)                 :: cc(1:numc,0:nlev)

! !OUTPUT PARAMETERS:
   REALTYPE, intent(out)                :: pp(1:numc,1:numc,0:nlev)
   REALTYPE, intent(out)                :: dd(1:numc,1:numc,0:nlev)
!
! !REVISION HISTORY:
!  Original author(s): Hans Burchard, Karsten Bolding
!
!EOP
!-----------------------------------------------------------------------
!BOC
!  no right hand sides necessary

   pp=_ZERO_
   dd=_ZERO_

   return
   end subroutine do_bio_sed
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Finish the bio calculations
!
! !INTERFACE:
   subroutine end_bio_sed
!
! !DESCRIPTION:
!  Nothing done yet --- supplied for completeness.
!
! !USES:
   IMPLICIT NONE
!
! !REVISION HISTORY:
!  Original author(s): Hans Burchard & Karsten Bolding
!
!EOP
!-----------------------------------------------------------------------
!BOC

   return
   end subroutine end_bio_sed
!EOC

!-----------------------------------------------------------------------

   end module bio_sed

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!-----------------------------------------------------------------------
