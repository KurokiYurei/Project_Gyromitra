using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosion : MonoBehaviour
{
    [SerializeField]
    private float m_damage;

    private string m_playerTag;

    Animation m_animation;

    float m_timer;
    bool m_destroy;

    // Start is called before the first frame update
    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");

        m_animation = gameObject.GetComponent<Animation>();
    }

    // Update is called once per frame
    void Update()
    {
        if (m_animation.IsPlaying("Explosion"))
        {
            m_destroy = true;
        }

        if (m_destroy)
        {
            if(m_timer >= 0.3f)
            {
                Destroy(gameObject);
            }
            else
            {
                m_timer += Time.deltaTime;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(m_playerTag))
        {
            other.GetComponent<CharacterHP>().Damage(m_damage);
        }
    }
}
