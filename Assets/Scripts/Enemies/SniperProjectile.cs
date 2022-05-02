using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SniperProjectile : MonoBehaviour
{
    [SerializeField]
    private float m_damage = 25f;

    private void OnCollisionEnter(Collision collision)
    {
        Debug.DrawRay(collision.contacts[0].point, collision.contacts[0].normal, Color.red, 5f);

        if (collision.transform.CompareTag("Player"))
        {
            var l_character = collision.gameObject.GetComponent<CharacterHP>();
            l_character.Damage(m_damage);
        }
        gameObject.SetActive(false);
    }

}
