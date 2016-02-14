<?php

/* This file is part of Jeedom.
 *
 * Jeedom is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Jeedom is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Jeedom. If not, see <http://www.gnu.org/licenses/>.
 */

/* * ***************************Includes********************************* */
require_once dirname(__FILE__) . '/../../../../core/php/core.inc.php';

class torque extends eqLogic {
  public static function dependancy_info() {
    $return = array();
    $return['log'] = 'torque_dep';
    $return['state'] = 'ok';
    return $return;
  }

  public static function dependancy_install() {
    $resource_path = realpath(dirname(__FILE__) . '/../../resources');
    $url  = config::byKey('externalComplement') . '/core/api/jeeApi.php?api=' . config::byKey('api') . '&type=torque&';
    passthru('/bin/bash ' . $resource_path . '/reverse.sh ' . $resource_path . ' torque ' . $url . ' > ' . log::getPathToLog('torque_dep') . ' 2>&1 &');
  }

    public static function apiTorque() {
      //for reference https://github.com/econpy/torque/blob/master/web/upload_data.php
      $torqueid = init('id');
      log::add('torque', 'debug', 'api recue ');
      $elogic = self::byLogicalId($torqueid, 'torque');
      if (!is_object($elogic)) {
  				$torque = new torque();
  				$torque->setEqType_name('torque');
  				$torque->setLogicalId($torqueid);
  				$torque->setName('Torque - '.$torqueid);
  				$torque->setIsEnable(true);
  				$torque->save();
  		}
    foreach ($_GET as $key => $value) {
          log::add('torque', 'debug', 'argument ' . $key . ' valeur ' . $value);
          // Keep columns starting with k
          if (preg_match("/^k/", $key)) {
            torque::saveValue($torqueid, $key, $value);
          }
          else if (in_array($key, array("v", "eml", "time", "id", "session"))) {
            torque::saveValue($torqueid, $key, $value);
          }
    }
    echo 'OK!';
  }

    public static function saveValue($torqueid, $key, $value) {
      log::add('torque', 'debug', 'valeur recue');
      $elogic = self::byLogicalId($torqueid, 'torque');
      $cmdlogic = torqueCmd::byEqLogicIdAndLogicalId($elogic->getId(),$key);
      if (!is_object($cmdlogic)) {
        log::add('torque', 'debug', 'création commande ' . $key . ' valeur ' . $value);
        $newTorque = new torqueCmd();
        $newTorque->setEqLogic_id($elogic->getId());
        $newTorque->setEqType('torque');
        $newTorque->setIsVisible(1);
        $newTorque->setIsHistorized(0);
        $newTorque->setSubType('string');
        $newTorque->setType('info');
        $newTorque->setName( $key );
        $newTorque->setConfiguration('name', $key);
        $newTorque->setConfiguration('value', $value);
        $newTorque->setLogicalId($key);
        $newTorque->save();
      } else {
        log::add('torque', 'debug', 'valeur recue ' . $value);
        $cmdlogic->setConfiguration('value', $value);
        $cmdlogic->save();
        $cmdlogic->event($value);
    }
  }

  public function getInfo($_infos = '') {
      $url  = config::byKey('externalProtocol') . config::byKey('externalAddr') . ':' . config::byKey('externalPort') . config::byKey('externalComplement') . '/core/api/jeeApi.php?api=' . config::byKey('api') . '&type=torque&';
      $return = array();
          $return['api'] = array(
              'value' => $url,
              );
  return $return;
  }

    /*     * *********************Methode d'instance************************* */
    public static function event() {

  		/*$messageType = init('messagetype');
  		switch ($messageType) {

  			case 'saveValue' : self::saveValue(); break;
  		}*/
      torque::apiTorque();
      log::add('torque', 'debug', 'event recu');
  	}


    /*     * **********************Getteur Setteur*************************** */

}

class torqueCmd extends cmd {
    /*     * *************************Attributs****************************** */



    /*     * ***********************Methode static*************************** */

    /*     * *********************Methode d'instance************************* */
	public function execute($_options = null) {
	}

}

?>
