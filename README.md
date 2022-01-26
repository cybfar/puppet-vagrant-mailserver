<h3 align="center">Serveur de Messagerie</h3>

---

<p align="center"> Ceci est un projet de serveur de messagerie fait avec Postfix, Dovecot et Roundcube. Le déploiement automatique se fait avec Puppet.
    <br> 
</p>

## 🏁 Commencer <a name = "getting_started"></a>

Ces instructions vous permettront d'obtenir une copie du projet opérationnel sur votre ordinateur local à des fins de développement et de test. Voir le déploiement pour des notes sur la façon de déployer le projet sur un système automatiquement.

### Prérequis

Les prérequis pour pouvoir faire le déploiement automatique :

```
- Vagrant
- Virtualbox
- Git
```

### Installation

Pour pouvoir installer le serveur mail , il faut au préalable installer :

- [Vagrant](https://www.vagrantup.com/) - Installation de Vagrant
- [Virtualbox](https://www.virtualbox.org/) - Installation de Virtualbox
- [Git](https://git-scm.com/downloads) - Installation de Git


## 🚀 Deploiement <a name = "deployment"></a>

Pour lancer le déploiement automatique, il faut utiliser les commandes ci-dessous:

```
git clone https://github.com/cybfar/puppet-vagrant-mailserver.git
cd puppet-vagrant-mailserver
sudo chmod +x deploiement.sh (Sur les machines Linux !)
./deploiement.sh
```
