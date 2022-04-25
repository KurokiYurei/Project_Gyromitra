using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bramble : MonoBehaviour
{
    [SerializeField]
    private string m_playerTag;

    private float m_damage;

    private bool m_playerRecievedDamage;

    private IDamagable m_player;

    [SerializeField]
    private float m_pushPower;

    [SerializeField]
    private float m_pushDuration;

    // Start is called before the first frame update
    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");

        m_damage = 25f;

    }

    // Update is called once per frame
    void Update()
    {
        if (!m_playerRecievedDamage && m_player != null)
        {
            //m_player.Damage(m_damage);

        }
    }

    private void OnCollisionEnter(Collision other)
    {
        print("Patatatatatat");
        if (other.collider.CompareTag(m_playerTag))
        {
            print("Entro");
            m_player = other.collider.GetComponent<IDamagable>();
            other.gameObject.GetComponent<CharacterControllerScript>().SetBounceParameters(other.contacts[0].normal, m_pushPower, m_pushDuration);
            m_playerRecievedDamage = true;

        }
    }

    //private void OnTriggerEnter(Collider other)
    //{
    //    print("Entro");
    //    if (other.tag == m_playerTag)
    //    {

    //        m_player = other.GetComponent<IDamagable>();
    //        m_player.Damage(m_damage);
    //        other.GetComponent<CharacterControllerScript>().
    //        //other.GetComponent<CharacterControllerScript>().SetBounceParameters();
    //        //m_playerRecievedDamage = true;

    //    }
    //}

    //private void OnControllerColliderHit(ControllerColliderHit hit)
    //{
    //    print("Fa controller colider");
    //}

    //private void OnCollisionExit(Collision other)
    //{
    //    if (other.collider.tag == m_playerTag)
    //    {
    //        print("Surto");
    //        m_playerRecievedDamage = false;
    //    }
    //}

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            print("Surto");
            m_playerRecievedDamage = false;
        }
    }

}
